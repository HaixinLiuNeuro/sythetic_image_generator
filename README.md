# sythetic image generator 
GUI and function package to generate fluorescence and labeled image pairs of yeast cells written in MATLAB
 
# Background
## Yeasts 
Yeasts are eukaryotic, single-celled microorganisms. They reproduce by mitosis, or budding (asymmetric division). They vary in size, but typically 3-4 um in diameter. From the picture provided, the ones we work with likely vary from 2-6 in ellipse shape. They are used as model organism to study cell biology and used as platforms for protein screening. 

# Assumption
## cell
Individual cells could be modeled as an ellipse with a and b vary from **2-8 um**, and a rotation from the axis. 

Because yeasts are eukaryotic, with nucleus. Most expressed fluorescent proteins are not in nucleus. Thus, a more realistic image would have a much lighter nucleus region. The nucleus can be modeled as circular structure. For simplicity, we can position a circle as nucleus at the ellipse center with 0.9 of the minor axis length, with fluorescent intensity as 0.1 of the indicated fluorescent intensity. 

## location
Uniform distribution in the whole field. Allow cells to be cropped at the image edge. 

## noise
Two types commom of noise to be added. 
### read noise:
Assume Gaussian noise for all pixels in the image
### photon noise:
Assume Possion noise depending on the intensity of each pixel


# Use instruction
## GUI
![GUI Layout](https://github.com/HaixinLiuNeuro/sythetic_image_generator/blob/main/doc/UI_pic.png?raw=true)

The GUI allows user to 
1. specify parameters of the image and the noise of choice
2. preview a few images with the input parameters
3. generate a batch of images to a user specified folder

Here is one preview example. Left is the sythetic fluorescence image (uint16), right is the corresponding label image (uint8). 

![Preview Figure Example](https://github.com/HaixinLiuNeuro/sythetic_image_generator/blob/main/doc/UI_pic_preview_figure.png 'Preview Figure Example')

Here is one generated tiff pair. 

![Tiff Example](https://github.com/HaixinLiuNeuro/sythetic_image_generator/blob/main/doc/example_generated_tiffs.png 'Tiff Example')


## scripting
Use  [example script](https://www.google.com) to directly write images to folder



