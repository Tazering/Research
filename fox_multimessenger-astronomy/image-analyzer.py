import matplotlib.pyplot as plt
import matplotlib
import h5py
from PIL import Image

# with Image.open("./galaxy-em.jpg") as img:
#     img.load()

# print(img.mode)

# with h5py.File("./2016/03/21/TEST_MP_PXX_20160321_000000.h5", "r") as fp:
#     tod = fp["P/Phase1"].value
#     time = fp["TIME"].value

# plt.imshow(tod, aspect="auto",
#            extent=(time[0], time[-1],990, 1260),
#            cmap="gist_earth", norm=matplotlib.colors.LogNorm())
# plt.colorbar()

from astropy.io import fits

fits_image = fits.open("./1507p696_ac51-w1-int-3_ra148.8882208_dec69.06529472_asec600.000.fits")
print(fits_image.info())

# im = Image.open("./fitscut.jpg")
# print(im.getchannel)