using System.Threading.Tasks;
using Classifier.Web.Hubs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace Classifier.Web.Controllers
{
    public class ImageResultController : Controller
    {
        private readonly IHubContext<ImagesHub> hubContext;

        public ImageResultController(IHubContext<ImagesHub> hubContext)
        {
            this.hubContext = hubContext;
        }

        [HttpPost("api/imageprocessed")]
        public Task ImageProcessed([FromBody] object result)
        {
            return hubContext.Clients.All.SendAsync("imageProcessed", result);
        }
    }
}