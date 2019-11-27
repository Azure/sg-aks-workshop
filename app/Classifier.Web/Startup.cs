using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Classifier.Web.Hubs;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StackExchange.Redis;
using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;

namespace Classifier.Web
{
    public class Startup
    {
        bool running = true;

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHealthChecks()
                .AddCheck("self", () => running ? HealthCheckResult.Healthy() : HealthCheckResult.Unhealthy());
            services.AddApplicationInsightsTelemetry(Configuration["AppInsightsInstrumentationKey"]);
            services.AddControllers();
            services.AddRazorPages();
            services.AddSignalR();
            if (!string.IsNullOrEmpty(Configuration["REDIS_HOST"]))
                services.AddSignalR().AddStackExchangeRedis(options =>
                {
                    options.ConnectionFactory = async writer =>
                    {
                        var config = new ConfigurationOptions
                        {
                            AbortOnConnectFail = false
                        };
                        var redisHost = Configuration["REDIS_HOST"] ?? "localhost";
                        var redisPort = int.Parse(Configuration["REDIS_PORT"] ?? "6379");
                        // config.EndPoints.Add(IPAddress.Loopback, 0);
                        config.EndPoints.Add(redisHost, redisPort);
                        config.SetDefaultPorts();
                        var connection = await ConnectionMultiplexer.ConnectAsync(config, writer);
                        connection.ConnectionFailed += (_, e) =>
                        {
                            Console.WriteLine("Connection to Redis failed.");
                        };

                        if (!connection.IsConnected)
                        {
                            Console.WriteLine("Did not connect to Redis.");
                        }

                        return connection;
                    };
                });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
            }

            app.UseStaticFiles();
            app.UseRouting();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapHealthChecks("/health/ready", new HealthCheckOptions()
                {
                    Predicate = r => r.Tags.Contains("services")
                });
                endpoints.MapHealthChecks("/health/live", new HealthCheckOptions()
                {
                    Predicate = r => r.Name.Contains("self")
                });
                endpoints.Map("/switch", async context =>
                    {
                        running = !running;
                        await context.Response.WriteAsync($"{Environment.MachineName} running {running}");
                    });
                endpoints.MapRazorPages();
                endpoints.MapControllers();
                endpoints.MapHub<ImagesHub>("/imageshub");
            });
        }
    }
}
