# sythetic image generator 
GUI and function package to generate fluorescence and labeled image pairs of yeast cells written in MATLAB
 
# Background
## Yeast 
Yeasts are eukaryotic, single-celled microorganisms. They vary in size, but typically 3-4 um in diameter. The commom strain used in labs has a size from 2-12 in ellipse shape. They are used as model organism to study cell biology and used as platforms for protein screening. They reproduce by mitosis, or budding (asymmetric division), which is a feature to be added in this package.

# Assumption
## cell
Individual cells could be modeled as an ellipse with a and b vary from **2-8 um**, and a rotation from the axis. 

Because yeasts are eukaryotic, with nucleus. Most expressed fluorescent proteins are not in nucleus. Thus, a more realistic image would have a much lighter nucleus region. The nucleus can be modeled as circular structure. For simplicity, we can position a circle as nucleus at the ellipse center with 0.9 of the minor axis length, with fluorescent intensity as 0.1 of the indicated fluorescent intensity. 

## location
Uniform distribution in the whole field. Allow cells to be cropped at the image edge. Currenly, we assume cells in the image can overlap. 

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

### Parameters:

* image size (width and height) in pixel number
* image scale um/pixel, as it uses actual size estimate of a cell to generate cells
* the mean of the two axis of the ellipse to model a cell in um (default is 3 um)
* the std of the axises of the ellipse of a cell in um (default is 0.5 um)
* the limit of axis length of cells in um (default is [1 6]). The first number is min, 2nd is max, separated by space.
* number of cells to generate in each image: 1-255, as label image uses uint8 to code the mask identity. 
* mean and std of the simulated cell: we simulate cell fluorescence intensity using a random draw from a Gaussian. The image is in uint16 so that the target value can be from 0 to 2^16. 

### Hidden Parameters:
* nucleus:  nucleus is model as a circle with a radius that is smaller than the minor axis of the cell and is centered around the cell center.
   * The radius is draw from a Gaussian with default mean = 0.75 * minor axis of the cell and std = 0.02 * minor axis of the cell.    
   * The center location is draw from a Gaussian with a jitter drawn from a Gaussian with mean = 0 and std = 0.01 um.    
   * The parameters is defined in [gen_rois](https://github.com/HaixinLiuNeuro/sythetic_image_generator/blob/main/helper_functions/gen_rois.m). 
   * nucleus fluorescence intensity is design as 70% darker than the cytoplasma in [gen_images](https://github.com/HaixinLiuNeuro/sythetic_image_generator/blob/main/helper_functions/gen_images.m)
   
### Noise section:
* Check box indicate whether to include the certain type of noise during image generation
* Gaussian noise use the mean and std defined as fraction of the whole image depth scale (for uint16, it is 2^16). The default gives ~ 2000 with std of 70.
* Possion noise is added after adding Guassian noise (if selected). It is based the intensity of each pixel. 
* Noise simulation uses: imnoise matlab function.

Here is one preview example. Left is the sythetic fluorescence image (uint16), right is the corresponding label image (uint8). 

![Preview Figure Example](https://github.com/HaixinLiuNeuro/sythetic_image_generator/blob/main/doc/UI_pic_preview_figure.png 'Preview Figure Example')

Here is one generated tiff pair. 

![Tiff Example](https://github.com/HaixinLiuNeuro/sythetic_image_generator/blob/main/doc/example_generated_tiffs.png 'Tiff Example')


## Scripting
Use  [example script](https://www.google.com) to directly write images to folder


# Future Feature Improvement
## More sophisticated/realistic model for cell simulation. 
* use point spread function under microscopy condition (e.g., two-photon imaging) 

## Cell location restriction:
* non-overlapping 
* different distribution features
* user defined locations

## Optimize speed.
* current looping by ROIs is very slow for big cell number images
