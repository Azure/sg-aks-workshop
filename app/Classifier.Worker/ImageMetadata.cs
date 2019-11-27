using Newtonsoft.Json;

namespace Classifier.Worker
{
    public class ImageMetadata
    {
        public string ImageId { get; set; }
        public string EncodingFormat { get; set; }
        public string ThumbnailUrl { get; set; }
    }
}