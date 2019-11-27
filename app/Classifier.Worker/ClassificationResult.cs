using System;

namespace Classifier.Worker
{
    public class ClassificationResult
    {
        public string Id { get; } = Guid.NewGuid().ToString();
        public float Probability { get; set; }
        public string Label { get; set; }
        public string WorkerId { get; set; }
        public long TimeTaken { get; set; }
        public ImageMetadata Image { get; set; }
    }
}