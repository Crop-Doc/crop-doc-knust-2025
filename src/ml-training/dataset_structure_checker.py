import os

# Get the absolute path to the project root
current_file_path = os.path.abspath(__file__)  # Get the full path of the current script
ml_training_dir = os.path.dirname(current_file_path)  # Get ml-training directory
src_dir = os.path.dirname(ml_training_dir)  # Get src directory
project_root = os.path.dirname(src_dir)  # Get the project root directory

def check_dataset_structure(path):
    """Check and display your dataset structure"""
    print(f"🔍 Analyzing dataset at: {path}")
    print("=" * 50)

    if not os.path.exists(path):
        print(f" ERROR: Path '{path}' does not exist!")
        # Try to show available directories in the parent folder
        parent_dir = os.path.dirname(path)
        if os.path.exists(parent_dir):
            print(f"\n Available paths in {parent_dir}:")
            try:
                for item in os.listdir(parent_dir):
                    item_path = os.path.join(parent_dir, item)
                    if os.path.isdir(item_path):
                        print(f"{item}/")
                    else:
                        print(f"{item}")
            except PermissionError:
                print("  Permission denied when trying to list directory contents")
            except Exception as e:
                print(f"  Error listing directory: {str(e)}")
        else:
            print(f"\n Parent directory {parent_dir} also does not exist.")
        return False

    print(f" Path exists: {path}")
    print("\n Dataset Structure:")

    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.webp')
    total_images = 0
    crop_count = 0
    class_count = 0

    # Walk through directory structure
    for root, dirs, files in os.walk(path):
        level = root.replace(path, '').count(os.sep)
        indent = '  ' * level
        folder_name = os.path.basename(root)

        # Count images in current folder
        image_files = [f for f in files if f.lower().endswith(image_extensions)]
        other_files = [f for f in files if not f.lower().endswith(image_extensions)]

        # Skip hidden/system folders
        if folder_name.startswith('.') or folder_name == '__pycache__':
            continue

        print(f"{indent}📁 {folder_name}/ ({len(image_files)} images)")

        # Count crops and classes
        if level == 1:  # Crop level (maize, cassava, tomato)
            crop_count += 1
        elif level == 2:  # Disease class level
            class_count += 1

        total_images += len(image_files)

        # Show some image files
        if image_files:
            for img in image_files[:3]:  # Show first 3 images
                print(f"{indent}  📷 {img}")
            if len(image_files) > 3:
                print(f"{indent}  ... and {len(image_files) - 3} more images")

        # Show problematic files
        if other_files:
            problematic = [f for f in other_files if not f.startswith('.')]
            if problematic:
                print(f"{indent}  ⚠️  Non-image files: {problematic[:3]}")

    print("\n📊 Summary:")
    print(f"   Total crops found: {crop_count}")
    print(f"   Total disease classes: {class_count}")
    print(f"   Total images: {total_images}")

    # Expected structure
    print("\n✅ Expected Structure:")
    print("   your_dataset/")
    print("   ├── maize/")
    print("   │   ├── healthy/")
    #print("   │   ├── rust/")
    print("   │   └── blight/")
    print("   ├── cassava/")
    print("   │   ├── healthy/")
    print("   │   ├── mosaic/")
    #print("   │   └── brown_streak/")
    print("   └── tomato/")
    print("       ├── healthy/")
    print("       ├── early_blight/")
    print("       └── late_blight/")

    return total_images > 0


# Check your dataset
# Use an absolute path to the dataset folder
DATASET_PATH = os.path.join(project_root, 'datasets', 'content')

success = check_dataset_structure(DATASET_PATH)

if not success:
    print("\n🔧 Next Steps:")
    print("1. Make sure your dataset is in the correct location")
    print("2. Make sure your images are organized in the expected structure")
    print("3. Remove any .ipynb_checkpoints folders")