import qrcode

url = "https://t.me/vcrocstudio"

qr = qrcode.QRCode(border=0)
qr.add_data(url)
qr.make(fit=True)

m = qr.get_matrix()

print("local qr = {")
for row in m:
    print('    "' + "".join("1" if x else "0" for x in row) + '",')
print("}")