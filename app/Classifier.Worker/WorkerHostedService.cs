using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using TensorFlow;

namespace Classifier.Worker
{
    public class WorkerHostedService : BackgroundService
    {
        public WorkerHostedService()
        {
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await DoWork(stoppingToken);
        }

        private async Task DoWork(CancellationToken stoppingToken)
        {
            var images = JsonConvert.DeserializeObject<ImageMetadata[]>(File.ReadAllText("assets/images/images.json"));
            var rand = new Random();
            var graph = new TFGraph();
            var model = File.ReadAllBytes("assets/model.pb");
            var labels = File.ReadAllLines("assets/labels.txt");
            var hostname = Guid.NewGuid().ToString();
            var jsonSettings = new JsonSerializerSettings
            {
                ContractResolver = new CamelCasePropertyNamesContractResolver()
            };
            var httpClient = new HttpClient();

            graph.Import(model);

            var sw = new Stopwatch();
            while (!stoppingToken.IsCancellationRequested)
            {
                using (var session = new TFSession(graph))
                {
                    var image = images[rand.Next(images.Length)];
                    sw.Reset();
                    sw.Start();
                    var tensor = ImageUtil.CreateTensorFromImageFile($"assets/images/{image.ImageId}.{image.EncodingFormat}");
                    var runner = session.GetRunner();
                    runner.AddInput(graph["Placeholder"][0], tensor).Fetch(graph["loss"][0]);
                    var output = runner.Run();
                    var result = output[0];
                    var apiBaseUrl = Environment.GetEnvironmentVariable("API_BASE_URL") ?? "http://localhost:5000";
                    
                    var probabilities = ((float[][])result.GetValue(jagged: true))[0];
                    var highestProbability = probabilities
                        .Select((p, i) => (Probability: p, Index: i))
                        .OrderByDescending(p => p.Probability)
                        .First();
                    var bestResult = (Label: labels[highestProbability.Index], Probability: highestProbability.Probability);
                    Thread.Sleep(Convert.ToInt32(sw.ElapsedMilliseconds)+1000);
                    sw.Stop();

                    var classificationResult = new ClassificationResult
                    {
                        Image = image,
                        Label = bestResult.Label,
                        Probability = bestResult.Probability,
                        WorkerId = hostname,
                        TimeTaken = sw.ElapsedMilliseconds
                    };

                    Console.WriteLine(JsonConvert.SerializeObject(classificationResult, jsonSettings));
                    var content = new StringContent(
                        JsonConvert.SerializeObject(classificationResult, jsonSettings),
                        Encoding.UTF8,
                        "application/json"
                    );
                    try
                    {
                        await httpClient.PostAsync($"{apiBaseUrl}/api/imageprocessed", content);
                    }
                    catch (Exception e) {
                        Console.WriteLine(e.ToString());
                    }

                    tensor.Dispose();
                    foreach(var o in output)
                    {
                        o.Dispose();
                    }
                }
            }
        }

        public override async Task StopAsync(CancellationToken stoppingToken)
        {
            await base.StopAsync(stoppingToken);
        }
    }
}