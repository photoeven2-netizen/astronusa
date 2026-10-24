import openpyxl
import json

wb = openpyxl.load_workbook(r'E:\Data_Kabupaten_Kota_Indonesia.xlsx')
sheet = wb.active

PROVINCE_COORDS = {
    'Aceh': { 'lat': 4.6951, 'lon': 96.7494, 'tz': 'Asia/Jakarta' },
    'Sumatera Utara': { 'lat': 2.1154, 'lon': 99.5451, 'tz': 'Asia/Jakarta' },
    'Sumatera Barat': { 'lat': -0.7399, 'lon': 100.8000, 'tz': 'Asia/Jakarta' },
    'Riau': { 'lat': 0.2933, 'lon': 101.7068, 'tz': 'Asia/Jakarta' },
    'Kepulauan Riau': { 'lat': 3.9456, 'lon': 108.1428, 'tz': 'Asia/Jakarta' },
    'Jambi': { 'lat': -1.4852, 'lon': 103.6161, 'tz': 'Asia/Jakarta' },
    'Bengkulu': { 'lat': -3.8004, 'lon': 102.2655, 'tz': 'Asia/Jakarta' },
    'Sumatera Selatan': { 'lat': -3.3194, 'lon': 104.9147, 'tz': 'Asia/Jakarta' },
    'Kepulauan Bangka Belitung': { 'lat': -2.7411, 'lon': 106.4406, 'tz': 'Asia/Jakarta' },
    'Lampung': { 'lat': -4.5586, 'lon': 105.4068, 'tz': 'Asia/Jakarta' },
    'Banten': { 'lat': -6.4058, 'lon': 106.0640, 'tz': 'Asia/Jakarta' },
    'DKI Jakarta': { 'lat': -6.2088, 'lon': 106.8456, 'tz': 'Asia/Jakarta' },
    'Jawa Barat': { 'lat': -6.9175, 'lon': 107.6191, 'tz': 'Asia/Jakarta' },
    'Jawa Tengah': { 'lat': -7.1510, 'lon': 110.1403, 'tz': 'Asia/Jakarta' },
    'D.I. Yogyakarta': { 'lat': -7.7956, 'lon': 110.3695, 'tz': 'Asia/Jakarta' },
    'DI Yogyakarta': { 'lat': -7.7956, 'lon': 110.3695, 'tz': 'Asia/Jakarta' },
    'Jawa Timur': { 'lat': -7.5360, 'lon': 112.2384, 'tz': 'Asia/Jakarta' },
    'Bali': { 'lat': -8.4095, 'lon': 115.1889, 'tz': 'Asia/Makassar' },
    'Nusa Tenggara Barat': { 'lat': -8.6529, 'lon': 117.3616, 'tz': 'Asia/Makassar' },
    'Nusa Tenggara Barat (NTB)': { 'lat': -8.6529, 'lon': 117.3616, 'tz': 'Asia/Makassar' },
    'Nusa Tenggara Timur': { 'lat': -8.6574, 'lon': 121.0794, 'tz': 'Asia/Makassar' },
    'Nusa Tenggara Timur (NTT)': { 'lat': -8.6574, 'lon': 121.0794, 'tz': 'Asia/Makassar' },
    'Kalimantan Barat': { 'lat': -0.2787, 'lon': 111.4753, 'tz': 'Asia/Pontianak' },
    'Kalimantan Tengah': { 'lat': -1.6815, 'lon': 113.3824, 'tz': 'Asia/Jakarta' },
    'Kalimantan Selatan': { 'lat': -3.0926, 'lon': 115.2838, 'tz': 'Asia/Makassar' },
    'Kalimantan Timur': { 'lat': 0.5387, 'lon': 116.4194, 'tz': 'Asia/Makassar' },
    'Kalimantan Utara': { 'lat': 3.0731, 'lon': 116.0414, 'tz': 'Asia/Makassar' },
    'Sulawesi Utara': { 'lat': 0.6247, 'lon': 123.9750, 'tz': 'Asia/Makassar' },
    'Gorontalo': { 'lat': 0.6999, 'lon': 122.4467, 'tz': 'Asia/Makassar' },
    'Sulawesi Tengah': { 'lat': -1.4300, 'lon': 121.4456, 'tz': 'Asia/Makassar' },
    'Sulawesi Barat': { 'lat': -2.8441, 'lon': 119.2321, 'tz': 'Asia/Makassar' },
    'Sulawesi Selatan': { 'lat': -3.6687, 'lon': 119.9740, 'tz': 'Asia/Makassar' },
    'Sulawesi Tenggara': { 'lat': -4.1449, 'lon': 122.1746, 'tz': 'Asia/Makassar' },
    'Maluku': { 'lat': -3.2385, 'lon': 130.1453, 'tz': 'Asia/Jayapura' },
    'Maluku Utara': { 'lat': 1.5709, 'lon': 127.8087, 'tz': 'Asia/Jayapura' },
    'Papua': { 'lat': -2.5489, 'lon': 140.7181, 'tz': 'Asia/Jayapura' },
    'Papua Barat': { 'lat': -1.3361, 'lon': 133.1747, 'tz': 'Asia/Jayapura' },
    'Papua Selatan': { 'lat': -8.4991, 'lon': 140.4013, 'tz': 'Asia/Jayapura' },
    'Papua Tengah': { 'lat': -3.3686, 'lon': 135.5305, 'tz': 'Asia/Jayapura' },
    'Papua Pegunungan': { 'lat': -4.0932, 'lon': 138.9442, 'tz': 'Asia/Jayapura' },
    'Papua Barat Daya': { 'lat': -0.8761, 'lon': 131.2558, 'tz': 'Asia/Jayapura' },
}

EXACT_CITY_COORDS = {
  'kota tangerang': { 'lat': -6.1783, 'lon': 106.6319 },
  'kabupaten tangerang': { 'lat': -6.1731, 'lon': 106.4673 },
  'kota tangerang selatan': { 'lat': -6.2886, 'lon': 106.7179 },
  'kabupaten tabanan': { 'lat': -8.5411, 'lon': 115.1226 },
  'kota denpasar': { 'lat': -8.6705, 'lon': 115.2126 },
  'kabupaten klaten': { 'lat': -7.7058, 'lon': 110.6064 },
  'kabupaten tuban': { 'lat': -6.8973, 'lon': 112.0649 },
  'kota surabaya': { 'lat': -7.2575, 'lon': 112.7521 },
  'kota bandung': { 'lat': -6.9175, 'lon': 107.6191 },
  'kota medan': { 'lat': 3.5952, 'lon': 98.6722 },
  'kota makassar': { 'lat': -5.1477, 'lon': 119.4327 },
  'kota jayapura': { 'lat': -2.5489, 'lon': 140.7181 },
  'kota semarang': { 'lat': -6.9667, 'lon': 110.4167 },
  'kota yogyakarta': { 'lat': -7.7956, 'lon': 110.3695 },
  'kota serang': { 'lat': -6.1200, 'lon': 106.1500 },
  'kota cilegon': { 'lat': -6.0167, 'lon': 106.0167 },
}

# Malaysia, Singapore, Thailand Cities
OTHER_CITIES = [
  # Malaysia
  { 'name': 'Kuala Lumpur', 'province': 'W.P. Kuala Lumpur', 'regionCode': 'MY-14', 'lat': 3.1390, 'lon': 101.6869, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'Putrajaya', 'province': 'W.P. Putrajaya', 'regionCode': 'MY-16', 'lat': 2.9264, 'lon': 101.6964, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'Labuan', 'province': 'W.P. Labuan', 'regionCode': 'MY-15', 'lat': 5.2831, 'lon': 115.2308, 'tz': 'Asia/Kuching' },
  { 'name': 'Shah Alam', 'province': 'Selangor', 'regionCode': 'MY-10', 'lat': 3.0738, 'lon': 101.5183, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'Petaling Jaya', 'province': 'Selangor', 'regionCode': 'MY-10', 'lat': 3.1073, 'lon': 101.6067, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'Johor Bahru', 'province': 'Johor', 'regionCode': 'MY-01', 'lat': 1.4927, 'lon': 103.7414, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'George Town', 'province': 'Pulau Pinang', 'regionCode': 'MY-07', 'lat': 5.4164, 'lon': 100.3327, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'Ipoh', 'province': 'Perak', 'regionCode': 'MY-08', 'lat': 4.5975, 'lon': 101.0901, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'Melaka', 'province': 'Melaka', 'regionCode': 'MY-04', 'lat': 2.1896, 'lon': 102.2501, 'tz': 'Asia/Kuala_Lumpur' },
  { 'name': 'Kota Kinabalu', 'province': 'Sabah', 'regionCode': 'MY-12', 'lat': 5.9804, 'lon': 116.0735, 'tz': 'Asia/Kuching' },
  { 'name': 'Kuching', 'province': 'Sarawak', 'regionCode': 'MY-13', 'lat': 1.5533, 'lon': 110.3592, 'tz': 'Asia/Kuching' },

  # Singapore
  { 'name': 'Singapore (City Centre)', 'province': 'Central Region', 'regionCode': 'SG-01', 'lat': 1.3521, 'lon': 103.8198, 'tz': 'Asia/Singapore' },
  { 'name': 'Orchard', 'province': 'Central Region', 'regionCode': 'SG-01', 'lat': 1.3048, 'lon': 103.8318, 'tz': 'Asia/Singapore' },
  { 'name': 'Marina Bay', 'province': 'Central Region', 'regionCode': 'SG-01', 'lat': 1.2840, 'lon': 103.8607, 'tz': 'Asia/Singapore' },
  { 'name': 'Woodlands', 'province': 'North Region', 'regionCode': 'SG-02', 'lat': 1.4382, 'lon': 103.7890, 'tz': 'Asia/Singapore' },
  { 'name': 'Jurong East', 'province': 'West Region', 'regionCode': 'SG-05', 'lat': 1.3329, 'lon': 103.7436, 'tz': 'Asia/Singapore' },

  # Thailand
  { 'name': 'Bangkok', 'province': 'Bangkok', 'regionCode': 'TH-10', 'lat': 13.7563, 'lon': 100.5018, 'tz': 'Asia/Bangkok' },
  { 'name': 'Nonthaburi', 'province': 'Nonthaburi', 'regionCode': 'TH-12', 'lat': 13.8591, 'lon': 100.5217, 'tz': 'Asia/Bangkok' },
  { 'name': 'Chiang Mai', 'province': 'Chiang Mai', 'regionCode': 'TH-50', 'lat': 18.7883, 'lon': 98.9853, 'tz': 'Asia/Bangkok' },
  { 'name': 'Phuket', 'province': 'Phuket', 'regionCode': 'TH-83', 'lat': 7.8804, 'lon': 98.3923, 'tz': 'Asia/Bangkok' },
  { 'name': 'Pattaya', 'province': 'Chonburi', 'regionCode': 'TH-20', 'lat': 12.9236, 'lon': 100.8825, 'tz': 'Asia/Bangkok' },
]

cities = []
id_counter = 1

for i, row in enumerate(sheet.iter_rows(values_only=True)):
    if i == 0 or not row[0]: continue
    prov, jenis, nama = str(row[0]).strip(), str(row[1]).strip(), str(row[2]).strip()

    fullName = f'{jenis} {nama}' if jenis in ['Kabupaten', 'Kota'] else nama
    lowerFull = fullName.toLowerCase() if hasattr(fullName, 'toLowerCase') else fullName.lower()

    pInfo = PROVINCE_COORDS.get(prov, { 'lat': -2.5489, 'lon': 118.0149, 'tz': 'Asia/Jakarta' })
    exact = EXACT_CITY_COORDS.get(lowerFull)

    lat = exact['lat'] if exact else pInfo['lat']
    lon = exact['lon'] if exact else pInfo['lon']

    cities.append({
        'id': id_counter,
        'name': fullName,
        'province': prov,
        'regionCode': f'ID-{(id_counter % 90) + 10}',
        'latitude': lat,
        'longitude': lon,
        'timeZone': pInfo['tz'],
        'population': 500000 if jenis == 'Kota' else 200000
    })
    id_counter += 1

# Append Malaysia, Singapore, Thailand
for o in OTHER_CITIES:
    cities.append({
        'id': id_counter,
        'name': o['name'],
        'province': o['province'],
        'regionCode': o['regionCode'],
        'latitude': o['lat'],
        'longitude': o['lon'],
        'timeZone': o['tz'],
        'population': 300000
    })
    id_counter += 1

outPath = r'E:\birth chart app\apps\astroguide\assets\data\indonesia_cities.json'
with open(outPath, 'w', encoding='utf-8') as f:
    json.dump(cities, f, ensure_ascii=False, indent=2)

print(f'Successfully generated {len(cities)} cities directly from E:\\Data_Kabupaten_Kota_Indonesia.xlsx!')
