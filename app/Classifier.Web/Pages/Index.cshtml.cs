using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;

namespace Classifier.Web.Pages
{
    public class IndexModel : PageModel
    {
        private readonly IConfiguration _configuration;
        public IndexModel(IConfiguration configuration){
            _configuration = configuration;
        }
        public string Message { get; set; }
        public void OnGet()
        {
            // Pull Secret from AKV
            Message = _configuration["AppSecret"];
        }
    }
}
