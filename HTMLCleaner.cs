using HtmlAgilityPack;

namespace FFAWMT.Services
{
    public static class HtmlCleaner
    {
        public static string StripHtml(string html)
        {
            if (string.IsNullOrWhiteSpace(html))
                return "";

            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            return HtmlEntity.DeEntitize(doc.DocumentNode.InnerText).Trim();
        }
    }
}
