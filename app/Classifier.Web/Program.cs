using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Configuration.AzureKeyVault;

namespace Classifier.Web
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BuildWebHost(args).Run();
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .ConfigureAppConfiguration((builderContext, config) =>
                {
                    config.AddJsonFile("keyvaultsettings.json", optional:true, reloadOnChange: true);
                    config.AddEnvironmentVariables();
                    var configuration = config.Build();

                    // Configure Azure Key Vault Connection
                    var uri = $"https://{configuration["KeyVault:Vault"]}.vault.azure.net/";
                    var clientId = configuration["KeyVault:ClientId"];
                    var clientSecret = configuration["KeyVault:ClientSecret"];

                    if (string.IsNullOrEmpty(uri))
                        Console.WriteLine("KeyVault name is missing(KeyVault:Vault Config Value)");

                    // Check, if Client ID and Client Secret credentials for a Service Principal
                    // have been provided. If so, use them to connect, otherwise let the connection 
                    // be done automatically in the background
                    if (!string.IsNullOrEmpty(clientId) && !string.IsNullOrEmpty(clientSecret))
                        config.AddAzureKeyVault(uri, clientId, clientSecret);
                    else
                        config.AddAzureKeyVault(uri);
                })
                .UseStartup<Startup>()
                .Build();
    }
}
