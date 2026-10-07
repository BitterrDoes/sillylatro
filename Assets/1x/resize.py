import sys
import shutil
from PIL import Image
import os

def upscale_pixel_art(input_image, output_directory, input_image_path):
    # Double the size
    new_size = (input_image.width * 2, input_image.height * 2)
    resized_image = input_image.resize(new_size, Image.NEAREST)  # NEAREST resampling preserves pixelation

    # Save the resized image
    filename = os.path.basename(input_image_path)
    output_image_path = os.path.join(output_directory, filename)
    resized_image.save(output_image_path)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: py resize.py <input_image/directory>")
        sys.exit(1)

    input_path = sys.argv[1]

    if os.path.isdir(input_path):
        base_output = os.path.join("..", "2x")
        folder_name = os.path.basename(input_path)
        output_directory = os.path.join(base_output, folder_name)

        if os.path.exists(output_directory):
            shutil.rmtree(output_directory)

        os.makedirs(output_directory)

        for file in os.listdir(input_path):
            full_path = os.path.join(input_path, file)
            if not os.path.isfile(full_path):
                continue
            try:
                input_image = Image.open(full_path)
                upscale_pixel_art(input_image, output_directory, file)
            except:
                pass
            
    else:
        input_image = Image.open(input_path)
        output_directory = "../2x/"
        upscale_pixel_art(input_image, output_directory, input_path)