import treepoem

img = treepoem.generate_barcode(
    barcode_type='qrcode',
    data='https://jonasneubert.com/talks/pybay2018.html',
    options={"eclevel": "Q"}
)

img.convert('1').save('../../Output/qr.gif')