namespace PhongTroAPI.Entities.Embedded
{
    public class HinhAnhItem
    {
        public int MaAnh { get; set; }
        public string Url { get; set; } = string.Empty;
        public string? MoTa { get; set; }
        public bool IsMain { get; set; }
        
        // For compatibility with some controllers
        public string UrlAnh { get { return Url; } set { Url = value; } }
    }
}
