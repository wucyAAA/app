from PIL import Image
import os

def process_icon():
    source_path = 'assets/favicon.png'
    dest_path = 'assets/icon_opaque.png'

    if not os.path.exists(source_path):
        print(f"Error: {source_path} not found.")
        return

    try:
        with Image.open(source_path) as img:
            print(f"Original resolution: {img.size}")

            # Use original size
            width, height = img.size

            # Create white background
            background = Image.new('RGBA', (width, height), (255, 255, 255, 255))

            # Ensure source has alpha
            source = img.convert('RGBA')

            # Composite
            background.paste(source, (0, 0), source)

            # Convert to RGB to ensure opacity (remove alpha channel)
            final_output = background.convert('RGB')

            final_output.save(dest_path)
            print(f"Saved opaque icon to {dest_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    process_icon()
