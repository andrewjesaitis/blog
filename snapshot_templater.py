import datetime
import os
import glob
import string
import argparse

def list_of_images(directory):
    paths = glob.glob(f'{directory}/*.jpg') + glob.glob(f'{directory}/*.png')
    return [os.path.split(path)[1] for path in paths]

def list_of_markdown_files(directory):
    paths = glob.glob(f"{directory}/*.md")
    return [os.path.split(path)[1] for path in paths]

def image_filename_to_date(image_filename):
    date_str = os.path.splitext(image_filename)[0]
    YYYY, MM, DD = date_str.split('.')
    date_obj = datetime.date(int(YYYY), int(MM), int(DD))
    return date_obj.isoformat()

def images_needing_markdown(image_directory, markdown_directory):
    images = list_of_images(image_directory)
    markdown_files = list_of_markdown_files(markdown_directory)
    markdown_files_without_extension = [os.path.splitext(markdown_file)[0] for markdown_file in markdown_files]
    for image in images:
        if os.path.splitext(image)[0] not in markdown_files_without_extension:
            yield image

def convert_image_to_markdown(image_filename, template):
    post_date = image_filename_to_date(image_filename)
    template = string.Template(template)
    return template.substitute(post_date=post_date, img_file_name=image_filename)

def main():
    parser = argparse.ArgumentParser(description='Convert images to markdown')
    parser.add_argument('--template', required=True, help='Template for markdown file')
    parser.add_argument('--directory', required=True, help='Directory to search for images')
    parser.add_argument('--output', required=True, help='Directory to output markdown files')
    parser.add_argument('--verbose', action='store_true', help='Print out the created markdown files')
    args = parser.parse_args()
    for image in images_needing_markdown(args.directory, args.output):
        with open(args.template, 'r') as template_file:
            template = ''.join(template_file.readlines())
        if args.verbose:
            print(f"Creating markdown file for {image}")
        markdown = convert_image_to_markdown(image, template)
        markdown_filename = os.path.join(args.output, os.path.splitext(image)[0] + '.md')
        with open(markdown_filename, 'w') as f:
            f.write(markdown)

if __name__ == '__main__':
    main()