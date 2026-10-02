CREATE DATABASE [QuanLyPhongTro]
GO
USE [QuanLyPhongTro]
GO
/****** Object:  Table [dbo].[CoSo]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoSo](
	[MaCoSo] [int] IDENTITY(1,1) NOT NULL,
	[TenCoSo] [nvarchar](150) NOT NULL,
	[DiaChi] [nvarchar](255) NOT NULL,
	[MoTa] [nvarchar](max) NULL,
	[LoaiHinh] [nvarchar](100) NULL,
	[MaQuanLy] [int] NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[DanhGia] [float] NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayTao] [datetime] NULL,
	[DonGiaDien] [decimal](18, 2) NOT NULL,
	[DonGiaNuoc] [decimal](18, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaCoSo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Phong]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Phong](
	[MaPhong] [int] IDENTITY(1,1) NOT NULL,
	[MaCoSo] [int] NOT NULL,
	[SoPhong] [nvarchar](20) NOT NULL,
	[Tang] [int] NULL,
	[DienTich] [float] NULL,
	[GiaThue] [decimal](18, 2) NOT NULL,
	[SoNguoiToiDa] [int] NULL,
	[TrangThai] [nvarchar](50) NULL,
	[MoTa] [nvarchar](max) NULL,
	[NgayTao] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaPhong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[View_CoSo_TongQuan]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- 2. TẠO CÁC VIEWS
-- =========================================================

CREATE VIEW [dbo].[View_CoSo_TongQuan] AS
SELECT 
    cs.MaCoSo,
    cs.TenCoSo,
    cs.DiaChi,
    COUNT(p.MaPhong) AS TongPhong,
    SUM(CASE WHEN p.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS PhongTrong,
    SUM(CASE WHEN p.TrangThai = N'Đang thuê' THEN 1 ELSE 0 END) AS DangThue,
    SUM(CASE WHEN p.TrangThai = N'Bảo trì' THEN 1 ELSE 0 END) AS BaoTri
FROM CoSo cs
LEFT JOIN Phong p ON cs.MaCoSo = p.MaCoSo
GROUP BY cs.MaCoSo, cs.TenCoSo, cs.DiaChi;
GO
/****** Object:  View [dbo].[View_Phong_UI]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_Phong_UI] AS
SELECT 
    p.MaPhong,
    p.MaCoSo,
    cs.TenCoSo,
    cs.DiaChi,
    p.SoPhong,
    p.Tang,
    p.DienTich,
    p.GiaThue,
    p.SoNguoiToiDa,
    p.TrangThai,
    p.MoTa,
    p.TrangThai AS TrangThaiHienThi
FROM Phong p
JOIN CoSo cs ON p.MaCoSo = cs.MaCoSo;
GO
/****** Object:  Table [dbo].[KhachThue]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KhachThue](
	[MaKhach] [int] IDENTITY(1,1) NOT NULL,
	[HoTen] [nvarchar](100) NULL,
	[SDT] [varchar](15) NULL,
	[CCCD] [varchar](20) NULL,
	[Email] [varchar](100) NULL,
	[NgaySinh] [date] NULL,
	[GioiTinh] [nvarchar](10) NULL,
	[Dia ChiThuongTru] [nvarchar](255) NULL,
	[NgayCapCCCD] [date] NULL,
	[NoiCapCCCD] [nvarchar](155) NULL,
	[TrangThai] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaKhach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HoaDon]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HoaDon](
	[MaHoaDon] [int] IDENTITY(1,1) NOT NULL,
	[MaPhong] [int] NOT NULL,
	[MaKhach] [int] NULL,
	[Thang] [int] NOT NULL,
	[Nam] [int] NOT NULL,
	[TienPhong] [decimal](18, 2) NOT NULL,
	[ChiSoDienCu] [int] NOT NULL,
	[ChiSoDienMoi] [int] NOT NULL,
	[DonGiaDien] [decimal](18, 2) NOT NULL,
	[ChiSoNuocCu] [int] NOT NULL,
	[ChiSoNuocMoi] [int] NOT NULL,
	[DonGiaNuoc] [decimal](18, 2) NOT NULL,
	[TienDichVu] [decimal](18, 2) NULL,
	[MoTaDichVu] [nvarchar](255) NULL,
	[PhuPhi] [decimal](18, 2) NULL,
	[MoTaPhuPhi] [nvarchar](255) NULL,
	[TongTien] [decimal](18, 2) NOT NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayLap] [date] NULL,
	[HanThanhToan] [date] NULL,
	[NgayThanhToan] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaHoaDon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[View_HoaDon_UI]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_HoaDon_UI] AS
SELECT 
    hd.MaHoaDon,
    hd.Thang,
    hd.Nam,
    hd.TongTien,
    hd.TrangThai,
    hd.HanThanhToan,
    p.SoPhong,
    cs.TenCoSo,
    k.HoTen AS TenKhachThu,
    hd.TienPhong,
    (hd.ChiSoDienMoi - hd.ChiSoDienCu) * hd.DonGiaDien AS TienDien,
    (hd.ChiSoNuocMoi - hd.ChiSoNuocCu) * hd.DonGiaNuoc AS TienNuoc,
    hd.TienDichVu,
    hd.PhuPhi
FROM [dbo].[HoaDon] hd
JOIN [dbo].[Phong] p ON hd.MaPhong = p.MaPhong
JOIN [dbo].[CoSo] cs ON p.MaCoSo = cs.MaCoSo
JOIN [dbo].[KhachThue] k ON hd.MaKhach = k.MaKhach;
GO
/****** Object:  Table [dbo].[CoSo_TienIch]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoSo_TienIch](
	[MaCoSo] [int] NOT NULL,
	[MaTienIch] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaCoSo] ASC,
	[MaTienIch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChiSoDienNuoc]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiSoDienNuoc](
	[MaChiSo] [int] IDENTITY(1,1) NOT NULL,
	[MaPhong] [int] NOT NULL,
	[Thang] [int] NOT NULL,
	[Nam] [int] NOT NULL,
	[ChiSoDienCu] [int] NOT NULL,
	[ChiSoDienMoi] [int] NULL,
	[ChiSoNuocCu] [int] NOT NULL,
	[ChiSoNuocMoi] [int] NULL,
	[DaLapHoaDon] [bit] NOT NULL,
	[NgayCapNhat] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaChiSo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HinhAnhCoSo]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HinhAnhCoSo](
	[MaAnh] [int] IDENTITY(1,1) NOT NULL,
	[MaCoSo] [int] NOT NULL,
	[UrlAnh] [nvarchar](max) NULL,
	[IsMain] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaAnh] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HinhAnhPhong]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HinhAnhPhong](
	[MaAnh] [int] IDENTITY(1,1) NOT NULL,
	[MaPhong] [int] NOT NULL,
	[UrlAnh] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaAnh] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HopDongThue]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HopDongThue](
	[MaHopDong] [int] IDENTITY(1,1) NOT NULL,
	[MaPhong] [int] NOT NULL,
	[MaKhach] [int] NOT NULL,
	[NgayBatDau] [date] NOT NULL,
	[NgayKetThuc] [date] NULL,
	[TienCoc] [decimal](18, 2) NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayTao] [datetime] NULL,
	[ChuKy] [nvarchar](max) NULL,
	[ChiSoDienCu] [int] NULL,
	[ChiSoNuocCu] [int] NULL,
	[UrlChuKyKhach] [nvarchar](max) NULL,
	[ContractHash] [varchar](255) NULL,
	[PublicKeyKhach] [varchar](max) NULL,
	[NgayKy] [datetime] NULL,
	[LyDoKetThucSom] [nvarchar](max) NULL,
	[NgayMuonKetThuc] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaHopDong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LichHenXemPhong]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LichHenXemPhong](
	[MaLichHen] [int] IDENTITY(1,1) NOT NULL,
	[MaKhach] [int] NULL,
	[HoTenKhach] [nvarchar](100) NOT NULL,
	[SDTKhach] [varchar](15) NOT NULL,
	[MaPhong] [int] NOT NULL,
	[ThoiGianHen] [datetime] NOT NULL,
	[GhiChu] [nvarchar](255) NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayTao] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaLichHen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LichSuGiaHan]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LichSuGiaHan](
	[MaGiaHan] [int] IDENTITY(1,1) NOT NULL,
	[MaHopDong] [int] NOT NULL,
	[NgayBatDauMoi] [date] NOT NULL,
	[NgayKetThucMoi] [date] NOT NULL,
	[GiaThueMoi] [decimal](18, 2) NOT NULL,
	[NgayThucHien] [datetime] NULL,
	[GhiChu] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaGiaHan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LichSuThanhToan]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LichSuThanhToan](
	[MaThanhToan] [int] IDENTITY(1,1) NOT NULL,
	[MaHoaDon] [int] NOT NULL,
	[SoTien] [decimal](18, 2) NOT NULL,
	[PhuongThuc] [nvarchar](50) NULL,
	[NgayThanhToan] [datetime] NULL,
	[NguoiGhiNhan] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaThanhToan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NganHang]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NganHang](
	[MaNganHang] [int] IDENTITY(1,1) NOT NULL,
	[TenNganHang] [nvarchar](150) NOT NULL,
	[TenVietTat] [nvarchar](50) NULL,
	[MaBin] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaNganHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NguoiQuanLy]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NguoiQuanLy](
	[MaQuanLy] [int] IDENTITY(1,1) NOT NULL,
	[HoTen] [nvarchar](100) NOT NULL,
	[SDT] [varchar](15) NULL,
	[Email] [varchar](100) NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayTao] [datetime] NULL,
	[SoTaiKhoan] [nvarchar](50) NULL,
	[TenTaiKhoan] [nvarchar](150) NULL,
	[MaNganHang] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaQuanLy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OGhep]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OGhep](
	[MaBaiDang] [int] IDENTITY(1,1) NOT NULL,
	[MaKhach] [int] NOT NULL,
	[TieuDe] [nvarchar](255) NOT NULL,
	[NoiDung] [nvarchar](max) NULL,
	[ChiPhiDuKien] [decimal](18, 2) NOT NULL,
	[KhuVuc] [nvarchar](150) NULL,
	[YeuCauGioiTinh] [nvarchar](10) NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayDang] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaBaiDang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Phong_TienIch]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Phong_TienIch](
	[MaPhong] [int] NOT NULL,
	[MaTienIch] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaPhong] ASC,
	[MaTienIch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SuCo]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SuCo](
	[MaSuCo] [int] IDENTITY(1,1) NOT NULL,
	[MaPhong] [int] NOT NULL,
	[MaKhach] [int] NOT NULL,
	[TieuDe] [nvarchar](255) NOT NULL,
	[MoTa] [nvarchar](max) NULL,
	[HinhAnh] [nvarchar](max) NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayBao] [datetime] NULL,
	[NgayXuLy] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSuCo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaiKhoan]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaiKhoan](
	[MaTaiKhoan] [int] IDENTITY(1,1) NOT NULL,
	[TenDangNhap] [varchar](50) NOT NULL,
	[MatKhau] [varchar](255) NOT NULL,
	[VaiTro] [nvarchar](50) NOT NULL,
	[MaQuanLy] [int] NULL,
	[MaKhach] [int] NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayTao] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaTaiKhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TienIch]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TienIch](
	[MaTienIch] [int] IDENTITY(1,1) NOT NULL,
	[TenTienIch] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaTienIch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TinNhan]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TinNhan](
	[MaTinNhan] [int] IDENTITY(1,1) NOT NULL,
	[MaNguoiGui] [int] NULL,
	[VaiTroNguoiGui] [nvarchar](50) NOT NULL,
	[MaNguoiNhan] [int] NULL,
	[VaiTroNguoiNhan] [nvarchar](50) NOT NULL,
	[NoiDung] [nvarchar](max) NOT NULL,
	[NgayGui] [datetime] NULL,
	[DaDoc] [bit] NULL,
	[MaQuanLy] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaTinNhan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ThongBao]    Script Date: 04/06/2026 9:45:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThongBao](
	[MaThongBao] [int] IDENTITY(1,1) NOT NULL,
	[MaKhach] [int] NOT NULL,
	[TieuDe] [nvarchar](255) NOT NULL,
	[NoiDung] [nvarchar](max) NULL,
	[DaDoc] [bit] NULL,
	[NgayGui] [datetime] NULL,
	[MaQuanLy] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaThongBao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[CoSo] ON 

INSERT [dbo].[CoSo] ([MaCoSo], [TenCoSo], [DiaChi], [MoTa], [LoaiHinh], [MaQuanLy], [Latitude], [Longitude], [DanhGia], [TrangThai], [NgayTao], [DonGiaDien], [DonGiaNuoc]) VALUES (1, N'KTX Sinh Viên A', N'Quận 1', N'quy tac', N'KTX', 1, 10.759842459095909, 106.69904139371432, 4.5, N'Hoạt động', CAST(N'2026-05-05T15:11:41.920' AS DateTime), CAST(3500.00 AS Decimal(18, 2)), CAST(20000.00 AS Decimal(18, 2)))
INSERT [dbo].[CoSo] ([MaCoSo], [TenCoSo], [DiaChi], [MoTa], [LoaiHinh], [MaQuanLy], [Latitude], [Longitude], [DanhGia], [TrangThai], [NgayTao], [DonGiaDien], [DonGiaNuoc]) VALUES (2, N'Nhà trọ Trung Tâm B', N'Quận 3', N'', N'Nhà trọ', 1, 10.7868, 106.6822, 4.2, N'Hoạt động', CAST(N'2026-05-05T15:11:41.920' AS DateTime), CAST(3500.00 AS Decimal(18, 2)), CAST(20000.00 AS Decimal(18, 2)))
INSERT [dbo].[CoSo] ([MaCoSo], [TenCoSo], [DiaChi], [MoTa], [LoaiHinh], [MaQuanLy], [Latitude], [Longitude], [DanhGia], [TrangThai], [NgayTao], [DonGiaDien], [DonGiaNuoc]) VALUES (3, N'Chung cư mini C', N'Thủ Đức', NULL, N'Chung cư', 2, 10.8506, 106.7719, 4.7, N'Hoạt động', CAST(N'2026-05-05T15:11:41.920' AS DateTime), CAST(3500.00 AS Decimal(18, 2)), CAST(20000.00 AS Decimal(18, 2)))
INSERT [dbo].[CoSo] ([MaCoSo], [TenCoSo], [DiaChi], [MoTa], [LoaiHinh], [MaQuanLy], [Latitude], [Longitude], [DanhGia], [TrangThai], [NgayTao], [DonGiaDien], [DonGiaNuoc]) VALUES (5, N't1', N'111', NULL, N'Nhà trọ', NULL, 10.775654529488586, 106.70153376752974, 0, N'Hoạt động', CAST(N'2026-05-07T14:10:36.947' AS DateTime), CAST(3500.00 AS Decimal(18, 2)), CAST(20000.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[CoSo] OFF
GO
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (1, 1)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (1, 3)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (1, 4)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (1, 5)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (1, 10)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (2, 1)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (2, 3)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (2, 4)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (3, 1)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (3, 2)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (3, 3)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (3, 4)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (3, 7)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (3, 9)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (3, 10)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (5, 2)
INSERT [dbo].[CoSo_TienIch] ([MaCoSo], [MaTienIch]) VALUES (5, 11)
GO
SET IDENTITY_INSERT [dbo].[ChiSoDienNuoc] ON 

INSERT [dbo].[ChiSoDienNuoc] ([MaChiSo], [MaPhong], [Thang], [Nam], [ChiSoDienCu], [ChiSoDienMoi], [ChiSoNuocCu], [ChiSoNuocMoi], [DaLapHoaDon], [NgayCapNhat]) VALUES (1, 2, 10, 2024, 1250, 1342, 430, 438, 1, CAST(N'2026-06-04T09:32:22.973' AS DateTime))
INSERT [dbo].[ChiSoDienNuoc] ([MaChiSo], [MaPhong], [Thang], [Nam], [ChiSoDienCu], [ChiSoDienMoi], [ChiSoNuocCu], [ChiSoNuocMoi], [DaLapHoaDon], [NgayCapNhat]) VALUES (2, 12, 10, 2024, 2100, 2185, 150, 156, 1, CAST(N'2026-06-04T09:32:22.973' AS DateTime))
INSERT [dbo].[ChiSoDienNuoc] ([MaChiSo], [MaPhong], [Thang], [Nam], [ChiSoDienCu], [ChiSoDienMoi], [ChiSoNuocCu], [ChiSoNuocMoi], [DaLapHoaDon], [NgayCapNhat]) VALUES (3, 24, 9, 2024, 300, 450, 80, 92, 1, CAST(N'2026-06-04T09:32:22.973' AS DateTime))
INSERT [dbo].[ChiSoDienNuoc] ([MaChiSo], [MaPhong], [Thang], [Nam], [ChiSoDienCu], [ChiSoDienMoi], [ChiSoNuocCu], [ChiSoNuocMoi], [DaLapHoaDon], [NgayCapNhat]) VALUES (4, 5, 10, 2024, 800, 865, 200, 210, 0, CAST(N'2026-06-04T09:32:22.973' AS DateTime))
INSERT [dbo].[ChiSoDienNuoc] ([MaChiSo], [MaPhong], [Thang], [Nam], [ChiSoDienCu], [ChiSoDienMoi], [ChiSoNuocCu], [ChiSoNuocMoi], [DaLapHoaDon], [NgayCapNhat]) VALUES (5, 8, 10, 2024, 1500, NULL, 350, NULL, 0, CAST(N'2026-06-04T09:32:22.973' AS DateTime))
SET IDENTITY_INSERT [dbo].[ChiSoDienNuoc] OFF
GO
SET IDENTITY_INSERT [dbo].[HinhAnhCoSo] ON 

INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (1, 1, N'assets/images/co_so/co_so_1.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (2, 1, N'assets/images/co_so/co_so_1_2.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (3, 2, N'assets/images/co_so/co_so_2.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (4, 2, N'assets/images/co_so/co_so_2_2.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (5, 3, N'assets/images/co_so/co_so_3.jpg', 1)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (6, 3, N'assets/images/co_so/co_so_3_2.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (7, 2, N'http://localhost:5137/uploads/co_so/aa886217b8bd47fa9aed71ed772bc24e.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (8, 2, N'http://localhost:5137/uploads/co_so/d78ec6aba78b455dbafa1a5fa292c004.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (9, 2, N'http://localhost:5137/uploads/co_so/e35e1dfd2cf9408eb7ea0527a2ebf037.jpg', 1)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (11, 5, N'http://localhost:5137/uploads/co_so/cbb6293dfa3f4acd974cbeff04c8bc3c.jpg', 1)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (12, 1, N'http://localhost:5137/uploads/co_so/f99e54465dae432aa258153d0d288143.jpg', 0)
INSERT [dbo].[HinhAnhCoSo] ([MaAnh], [MaCoSo], [UrlAnh], [IsMain]) VALUES (13, 1, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/trosmart-images/coso_1_1780540798074.jpg', 1)
SET IDENTITY_INSERT [dbo].[HinhAnhCoSo] OFF
GO
SET IDENTITY_INSERT [dbo].[HinhAnhPhong] ON 

INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (6, 6, N'assets/images/phong/a106.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (7, 7, N'assets/images/phong/a107.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (8, 8, N'assets/images/phong/a108.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (9, 9, N'assets/images/phong/a109.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (19, 19, N'assets/images/phong/c101.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (20, 20, N'assets/images/phong/c102.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (21, 21, N'assets/images/phong/c103.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (22, 22, N'assets/images/phong/c104.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (23, 23, N'assets/images/phong/c105.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (24, 24, N'assets/images/phong/c106.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (25, 25, N'assets/images/phong/c107.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (26, 26, N'assets/images/phong/c108.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (30, 1, N'http://localhost:5137/uploads/phong/scaled_co_so_2_2_1_e38412914930425289b3ebe2ee5902e8.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (31, 10, N'http://localhost:5137/uploads/phong/scaled_co_so_2_2_1_07ebe15911cf411dabcd96a1407a53e9.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (32, 5, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/a105_coso1_20260604094105845.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (33, 2, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/a102_coso1_20260604094127472.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (34, 3, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/a103_coso1_20260604094208968.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (35, 4, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/a104_coso1_20260604094223480.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (36, 11, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b101_coso2_20260604094239536.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (37, 12, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b102_coso2_20260604094250783.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (38, 13, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b103_coso2_20260604094301313.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (39, 14, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b104_coso2_20260604094311516.webp')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (40, 15, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b105_coso2_20260604094323480.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (41, 16, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b106_coso2_20260604094334315.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (42, 17, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b107_coso2_20260604094347000.jpg')
INSERT [dbo].[HinhAnhPhong] ([MaAnh], [MaPhong], [UrlAnh]) VALUES (43, 18, N'https://rqrsmfmcnbptpuftbdiv.supabase.co/storage/v1/object/public/phong/b108_coso2_20260604094401602.jpg')
SET IDENTITY_INSERT [dbo].[HinhAnhPhong] OFF
GO
SET IDENTITY_INSERT [dbo].[HopDongThue] ON 

INSERT [dbo].[HopDongThue] ([MaHopDong], [MaPhong], [MaKhach], [NgayBatDau], [NgayKetThuc], [TienCoc], [TrangThai], [NgayTao], [ChuKy], [ChiSoDienCu], [ChiSoNuocCu], [UrlChuKyKhach], [ContractHash], [PublicKeyKhach], [NgayKy]) VALUES (1, 2, 1, CAST(N'2023-01-01' AS Date), NULL, CAST(2200000.00 AS Decimal(18, 2)), N'Đang hiệu lực', CAST(N'2026-06-04T09:32:22.960' AS DateTime), NULL, 1250, 430, NULL, NULL, NULL, NULL)
INSERT [dbo].[HopDongThue] ([MaHopDong], [MaPhong], [MaKhach], [NgayBatDau], [NgayKetThuc], [TienCoc], [TrangThai], [NgayTao], [ChuKy], [ChiSoDienCu], [ChiSoNuocCu], [UrlChuKyKhach], [ContractHash], [PublicKeyKhach], [NgayKy]) VALUES (2, 12, 2, CAST(N'2023-05-15' AS Date), NULL, CAST(2000000.00 AS Decimal(18, 2)), N'Đang hiệu lực', CAST(N'2026-06-04T09:32:22.960' AS DateTime), NULL, 2100, 150, NULL, NULL, NULL, NULL)
INSERT [dbo].[HopDongThue] ([MaHopDong], [MaPhong], [MaKhach], [NgayBatDau], [NgayKetThuc], [TienCoc], [TrangThai], [NgayTao], [ChuKy], [ChiSoDienCu], [ChiSoNuocCu], [UrlChuKyKhach], [ContractHash], [PublicKeyKhach], [NgayKy]) VALUES (3, 24, 3, CAST(N'2024-02-10' AS Date), NULL, CAST(2900000.00 AS Decimal(18, 2)), N'Đang hiệu lực', CAST(N'2026-06-04T09:32:22.960' AS DateTime), NULL, 300, 80, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[HopDongThue] OFF
GO
SET IDENTITY_INSERT [dbo].[KhachThue] ON 

INSERT [dbo].[KhachThue] ([MaKhach], [HoTen], [SDT], [CCCD], [Email], [NgaySinh], [GioiTinh], [Dia ChiThuongTru], [NgayCapCCCD], [NoiCapCCCD], [TrangThai]) VALUES (1, N'Nguyễn Văn An', N'0901234567', N'079099001122', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[KhachThue] ([MaKhach], [HoTen], [SDT], [CCCD], [Email], [NgaySinh], [GioiTinh], [Dia ChiThuongTru], [NgayCapCCCD], [NoiCapCCCD], [TrangThai]) VALUES (2, N'Trần Thị Bích', N'0912345678', N'079099001133', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[KhachThue] ([MaKhach], [HoTen], [SDT], [CCCD], [Email], [NgaySinh], [GioiTinh], [Dia ChiThuongTru], [NgayCapCCCD], [NoiCapCCCD], [TrangThai]) VALUES (3, N'Lê Minh Tuấn', N'0923456789', N'079099001144', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[KhachThue] OFF
GO
SET IDENTITY_INSERT [dbo].[NganHang] ON 

INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (1, N'Ngân hàng TMCP Công Thương Việt Nam', N'VietinBank', N'970415')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (2, N'Ngân hàng TMCP Ngoại thương Việt Nam', N'Vietcombank', N'970436')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (3, N'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam', N'BIDV', N'970418')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (4, N'Ngân hàng Nông nghiệp và Phát triển Nông thôn Việt Nam', N'Agribank', N'970405')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (5, N'Ngân hàng TMCP Kỹ Thương Việt Nam', N'Techcombank', N'970407')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (6, N'Ngân hàng TMCP Quân đội', N'MBBank', N'970422')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (7, N'Ngân hàng TMCP Á Châu', N'ACB', N'970416')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (8, N'Ngân hàng TMCP Sài Gòn Thương Tín', N'Sacombank', N'970403')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (9, N'Ngân hàng TMCP Việt Nam Thịnh Vượng', N'VPBank', N'970432')
INSERT [dbo].[NganHang] ([MaNganHang], [TenNganHang], [TenVietTat], [MaBin]) VALUES (10, N'Ngân hàng TMCP Tiên Phong', N'TPBank', N'970423')
SET IDENTITY_INSERT [dbo].[NganHang] OFF
GO
SET IDENTITY_INSERT [dbo].[NguoiQuanLy] ON 

INSERT [dbo].[NguoiQuanLy] ([MaQuanLy], [HoTen], [SDT], [Email], [TrangThai], [NgayTao], [SoTaiKhoan], [TenTaiKhoan], [MaNganHang]) VALUES (1, N'Nguyễn Văn A', N'0900000001', N'a@gmail.com', N'Hoạt động', CAST(N'2026-05-05T15:11:41.920' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[NguoiQuanLy] ([MaQuanLy], [HoTen], [SDT], [Email], [TrangThai], [NgayTao], [SoTaiKhoan], [TenTaiKhoan], [MaNganHang]) VALUES (2, N'Trần Văn B', N'0900000002', N'b@gmail.com', N'Hoạt động', CAST(N'2026-05-05T15:11:41.920' AS DateTime), NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[NguoiQuanLy] OFF
GO
SET IDENTITY_INSERT [dbo].[Phong] ON 

INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (1, 1, N'A101', 1, 20, CAST(2000000.00 AS Decimal(18, 2)), 2, N'Trống', N'oki', CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (2, 1, N'A102', 1, 22, CAST(2200000.00 AS Decimal(18, 2)), 2, N'Đang thuê', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (3, 1, N'A103', 1, 25, CAST(2500000.00 AS Decimal(18, 2)), 3, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (4, 1, N'A104', 2, 30, CAST(3000000.00 AS Decimal(18, 2)), 4, N'Bảo trì', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (5, 1, N'A105', 2, 28, CAST(2800000.00 AS Decimal(18, 2)), 3, N'Đang thuê', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (6, 1, N'A106', 2, 18, CAST(1800000.00 AS Decimal(18, 2)), 2, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (7, 1, N'A107', 3, 35, CAST(3500000.00 AS Decimal(18, 2)), 4, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (8, 1, N'A108', 3, 40, CAST(4000000.00 AS Decimal(18, 2)), 5, N'Đang thuê', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (9, 1, N'A109', 3, 22, CAST(2200000.00 AS Decimal(18, 2)), 2, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (10, 1, N'A110', 4, 45, CAST(4500000.00 AS Decimal(18, 2)), 5, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.920' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (11, 2, N'B101', 1, 18, CAST(1800000.00 AS Decimal(18, 2)), 2, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (12, 2, N'B102', 1, 20, CAST(2000000.00 AS Decimal(18, 2)), 2, N'Đang thuê', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (13, 2, N'B103', 2, 22, CAST(2200000.00 AS Decimal(18, 2)), 2, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (14, 2, N'B104', 2, 25, CAST(2500000.00 AS Decimal(18, 2)), 3, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (15, 2, N'B105', 2, 27, CAST(2700000.00 AS Decimal(18, 2)), 3, N'Đang thuê', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (16, 2, N'B106', 3, 30, CAST(3000000.00 AS Decimal(18, 2)), 4, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (17, 2, N'B107', 3, 32, CAST(3200000.00 AS Decimal(18, 2)), 4, N'Bảo trì', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (18, 2, N'B108', 3, 35, CAST(3500000.00 AS Decimal(18, 2)), 4, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (19, 3, N'C101', 1, 20, CAST(2100000.00 AS Decimal(18, 2)), 2, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (20, 3, N'C102', 1, 22, CAST(2300000.00 AS Decimal(18, 2)), 2, N'Đang thuê', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (21, 3, N'C103', 2, 25, CAST(2600000.00 AS Decimal(18, 2)), 3, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (22, 3, N'C104', 2, 28, CAST(2900000.00 AS Decimal(18, 2)), 3, N'Đang thuê', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (23, 3, N'C105', 2, 30, CAST(3100000.00 AS Decimal(18, 2)), 4, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (24, 3, N'C106', 3, 35, CAST(3600000.00 AS Decimal(18, 2)), 4, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (25, 3, N'C107', 3, 38, CAST(3800000.00 AS Decimal(18, 2)), 4, N'Bảo trì', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
INSERT [dbo].[Phong] ([MaPhong], [MaCoSo], [SoPhong], [Tang], [DienTich], [GiaThue], [SoNguoiToiDa], [TrangThai], [MoTa], [NgayTao]) VALUES (26, 3, N'C108', 3, 40, CAST(4000000.00 AS Decimal(18, 2)), 5, N'Trống', NULL, CAST(N'2026-05-05T15:11:41.923' AS DateTime))
SET IDENTITY_INSERT [dbo].[Phong] OFF
GO
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (1, 1)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (1, 2)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (1, 8)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (1, 9)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (2, 1)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (3, 2)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (4, 3)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (5, 4)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (6, 5)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (7, 6)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (8, 7)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (9, 8)
INSERT [dbo].[Phong_TienIch] ([MaPhong], [MaTienIch]) VALUES (10, 9)
GO
SET IDENTITY_INSERT [dbo].[SuCo] ON 

INSERT [dbo].[SuCo] ([MaSuCo], [MaPhong], [MaKhach], [TieuDe], [MoTa], [HinhAnh], [TrangThai], [NgayBao], [NgayXuLy]) VALUES (1, 2, 1, N'Hư bóng đèn', N'Bóng đèn nhà vệ sinh bị cháy', NULL, N'Chờ xử lý', NULL, NULL)
INSERT [dbo].[SuCo] ([MaSuCo], [MaPhong], [MaKhach], [TieuDe], [MoTa], [HinhAnh], [TrangThai], [NgayBao], [NgayXuLy]) VALUES (2, 12, 2, N'Rỉ nước bồn rửa chén', N'Nước nhỏ giọt liên tục', NULL, N'Đang xử lý', NULL, NULL)
SET IDENTITY_INSERT [dbo].[SuCo] OFF
GO
SET IDENTITY_INSERT [dbo].[TaiKhoan] ON 

INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenDangNhap], [MatKhau], [VaiTro], [MaQuanLy], [MaKhach], [TrangThai], [NgayTao]) VALUES (1, N'admin', N'123456', N'Admin', 1, NULL, N'Hoạt động', NULL)
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenDangNhap], [MatKhau], [VaiTro], [MaQuanLy], [MaKhach], [TrangThai], [NgayTao]) VALUES (2, N'khach1', N'123456', N'KhachThue', NULL, 1, N'Hoạt động', NULL)
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenDangNhap], [MatKhau], [VaiTro], [MaQuanLy], [MaKhach], [TrangThai], [NgayTao]) VALUES (3, N'khach2', N'123456', N'KhachThue', NULL, 2, N'Hoạt động', NULL)
SET IDENTITY_INSERT [dbo].[TaiKhoan] OFF
GO
SET IDENTITY_INSERT [dbo].[TienIch] ON 

INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (1, N'Wifi')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (2, N'Máy lạnh')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (3, N'Chỗ để xe')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (4, N'Camera')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (5, N'Giặt đồ')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (6, N'Bếp')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (7, N'Tủ lạnh')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (8, N'Ban công')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (9, N'Nội thất')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (10, N'Bảo vệ')
INSERT [dbo].[TienIch] ([MaTienIch], [TenTienIch]) VALUES (11, N'Gym')
SET IDENTITY_INSERT [dbo].[TienIch] OFF
GO
/****** Object:  Index [UQ_ChiSo_Phong_Thang_Nam]    Script Date: 04/06/2026 9:45:42 AM ******/
ALTER TABLE [dbo].[ChiSoDienNuoc] ADD  CONSTRAINT [UQ_ChiSo_Phong_Thang_Nam] UNIQUE NONCLUSTERED 
(
	[MaPhong] ASC,
	[Thang] ASC,
	[Nam] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__NguoiQua__CA1930A5BCC08ACF]    Script Date: 04/06/2026 9:45:42 AM ******/
ALTER TABLE [dbo].[NguoiQuanLy] ADD UNIQUE NONCLUSTERED 
(
	[SDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__TaiKhoan__55F68FC0F5782FB2]    Script Date: 04/06/2026 9:45:42 AM ******/
ALTER TABLE [dbo].[TaiKhoan] ADD UNIQUE NONCLUSTERED 
(
	[TenDangNhap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoSo] ADD  DEFAULT ((0)) FOR [DanhGia]
GO
ALTER TABLE [dbo].[CoSo] ADD  DEFAULT (N'Hoạt động') FOR [TrangThai]
GO
ALTER TABLE [dbo].[CoSo] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[CoSo] ADD  DEFAULT ((3500.00)) FOR [DonGiaDien]
GO
ALTER TABLE [dbo].[CoSo] ADD  DEFAULT ((20000.00)) FOR [DonGiaNuoc]
GO
ALTER TABLE [dbo].[ChiSoDienNuoc] ADD  DEFAULT ((0)) FOR [ChiSoDienCu]
GO
ALTER TABLE [dbo].[ChiSoDienNuoc] ADD  DEFAULT ((0)) FOR [ChiSoNuocCu]
GO
ALTER TABLE [dbo].[ChiSoDienNuoc] ADD  DEFAULT ((0)) FOR [DaLapHoaDon]
GO
ALTER TABLE [dbo].[ChiSoDienNuoc] ADD  DEFAULT (getdate()) FOR [NgayCapNhat]
GO
ALTER TABLE [dbo].[HinhAnhCoSo] ADD  CONSTRAINT [DF_HinhAnhCoSo_IsMain]  DEFAULT ((0)) FOR [IsMain]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT ((0)) FOR [TienDichVu]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT ((0)) FOR [PhuPhi]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT (N'Chưa thanh toán') FOR [TrangThai]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT (getdate()) FOR [NgayLap]
GO
ALTER TABLE [dbo].[HopDongThue] ADD  DEFAULT ((0)) FOR [TienCoc]
GO
ALTER TABLE [dbo].[HopDongThue] ADD  DEFAULT (N'Đang hiệu lực') FOR [TrangThai]
GO
ALTER TABLE [dbo].[HopDongThue] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[KhachThue] ADD  DEFAULT (N'Đang ở') FOR [TrangThai]
GO
ALTER TABLE [dbo].[LichHenXemPhong] ADD  DEFAULT (N'Chờ xác nhận') FOR [TrangThai]
GO
ALTER TABLE [dbo].[LichHenXemPhong] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[LichSuGiaHan] ADD  DEFAULT (getdate()) FOR [NgayThucHien]
GO
ALTER TABLE [dbo].[LichSuThanhToan] ADD  DEFAULT (getdate()) FOR [NgayThanhToan]
GO
ALTER TABLE [dbo].[NguoiQuanLy] ADD  DEFAULT (N'Hoạt động') FOR [TrangThai]
GO
ALTER TABLE [dbo].[NguoiQuanLy] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[OGhep] ADD  DEFAULT (N'Đang tìm') FOR [TrangThai]
GO
ALTER TABLE [dbo].[OGhep] ADD  DEFAULT (getdate()) FOR [NgayDang]
GO
ALTER TABLE [dbo].[Phong] ADD  DEFAULT (N'Trống') FOR [TrangThai]
GO
ALTER TABLE [dbo].[Phong] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[SuCo] ADD  DEFAULT (N'Chờ xử lý') FOR [TrangThai]
GO
ALTER TABLE [dbo].[SuCo] ADD  DEFAULT (getdate()) FOR [NgayBao]
GO
ALTER TABLE [dbo].[TaiKhoan] ADD  DEFAULT (N'Hoạt động') FOR [TrangThai]
GO
ALTER TABLE [dbo].[TaiKhoan] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[TinNhan] ADD  DEFAULT (getdate()) FOR [NgayGui]
GO
ALTER TABLE [dbo].[TinNhan] ADD  DEFAULT ((0)) FOR [DaDoc]
GO
ALTER TABLE [dbo].[ThongBao] ADD  DEFAULT ((0)) FOR [DaDoc]
GO
ALTER TABLE [dbo].[ThongBao] ADD  DEFAULT (getdate()) FOR [NgayGui]
GO
ALTER TABLE [dbo].[CoSo]  WITH CHECK ADD FOREIGN KEY([MaQuanLy])
REFERENCES [dbo].[NguoiQuanLy] ([MaQuanLy])
GO
ALTER TABLE [dbo].[CoSo_TienIch]  WITH CHECK ADD FOREIGN KEY([MaCoSo])
REFERENCES [dbo].[CoSo] ([MaCoSo])
GO
ALTER TABLE [dbo].[CoSo_TienIch]  WITH CHECK ADD FOREIGN KEY([MaTienIch])
REFERENCES [dbo].[TienIch] ([MaTienIch])
GO
ALTER TABLE [dbo].[ChiSoDienNuoc]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[Phong] ([MaPhong])
GO
ALTER TABLE [dbo].[HinhAnhCoSo]  WITH CHECK ADD FOREIGN KEY([MaCoSo])
REFERENCES [dbo].[CoSo] ([MaCoSo])
GO
ALTER TABLE [dbo].[HinhAnhPhong]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[Phong] ([MaPhong])
GO
ALTER TABLE [dbo].[HoaDon]  WITH CHECK ADD FOREIGN KEY([MaKhach])
REFERENCES [dbo].[KhachThue] ([MaKhach])
GO
ALTER TABLE [dbo].[HoaDon]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[Phong] ([MaPhong])
GO
ALTER TABLE [dbo].[HopDongThue]  WITH CHECK ADD FOREIGN KEY([MaKhach])
REFERENCES [dbo].[KhachThue] ([MaKhach])
GO
ALTER TABLE [dbo].[HopDongThue]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[Phong] ([MaPhong])
GO
ALTER TABLE [dbo].[LichHenXemPhong]  WITH CHECK ADD FOREIGN KEY([MaKhach])
REFERENCES [dbo].[KhachThue] ([MaKhach])
GO
ALTER TABLE [dbo].[LichHenXemPhong]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[Phong] ([MaPhong])
GO
ALTER TABLE [dbo].[LichSuGiaHan]  WITH CHECK ADD FOREIGN KEY([MaHopDong])
REFERENCES [dbo].[HopDongThue] ([MaHopDong])
GO
ALTER TABLE [dbo].[LichSuThanhToan]  WITH CHECK ADD FOREIGN KEY([MaHoaDon])
REFERENCES [dbo].[HoaDon] ([MaHoaDon])
GO
ALTER TABLE [dbo].[LichSuThanhToan]  WITH CHECK ADD FOREIGN KEY([NguoiGhiNhan])
REFERENCES [dbo].[NguoiQuanLy] ([MaQuanLy])
GO
ALTER TABLE [dbo].[NguoiQuanLy]  WITH CHECK ADD  CONSTRAINT [FK_NguoiQuanLy_NganHang] FOREIGN KEY([MaNganHang])
REFERENCES [dbo].[NganHang] ([MaNganHang])
GO
ALTER TABLE [dbo].[NguoiQuanLy] CHECK CONSTRAINT [FK_NguoiQuanLy_NganHang]
GO
ALTER TABLE [dbo].[OGhep]  WITH CHECK ADD FOREIGN KEY([MaKhach])
REFERENCES [dbo].[KhachThue] ([MaKhach])
GO
ALTER TABLE [dbo].[Phong]  WITH CHECK ADD FOREIGN KEY([MaCoSo])
REFERENCES [dbo].[CoSo] ([MaCoSo])
GO
ALTER TABLE [dbo].[Phong_TienIch]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[Phong] ([MaPhong])
GO
ALTER TABLE [dbo].[Phong_TienIch]  WITH CHECK ADD FOREIGN KEY([MaTienIch])
REFERENCES [dbo].[TienIch] ([MaTienIch])
GO
ALTER TABLE [dbo].[SuCo]  WITH CHECK ADD FOREIGN KEY([MaKhach])
REFERENCES [dbo].[KhachThue] ([MaKhach])
GO
ALTER TABLE [dbo].[SuCo]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[Phong] ([MaPhong])
GO
ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD FOREIGN KEY([MaKhach])
REFERENCES [dbo].[KhachThue] ([MaKhach])
GO
ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD FOREIGN KEY([MaQuanLy])
REFERENCES [dbo].[NguoiQuanLy] ([MaQuanLy])
GO
ALTER TABLE [dbo].[ThongBao]  WITH CHECK ADD FOREIGN KEY([MaKhach])
REFERENCES [dbo].[KhachThue] ([MaKhach])
GO
ALTER TABLE [dbo].[ThongBao]  WITH CHECK ADD FOREIGN KEY([MaQuanLy])
REFERENCES [dbo].[NguoiQuanLy] ([MaQuanLy])
GO
ALTER TABLE [dbo].[TinNhan]  WITH CHECK ADD FOREIGN KEY([MaQuanLy])
REFERENCES [dbo].[NguoiQuanLy] ([MaQuanLy])
GO
ALTER TABLE [dbo].[Phong]  WITH CHECK ADD  CONSTRAINT [CK_TrangThai] CHECK  (([TrangThai]=N'Bảo trì' OR [TrangThai]=N'Đang thuê' OR [TrangThai]=N'Trống'))
GO
ALTER TABLE [dbo].[Phong] CHECK CONSTRAINT [CK_TrangThai]
GO
