import argparse
import enum
import glob
import logging
import platform
import zipfile
from os import path
from typing import List

logging.basicConfig(level=logging.INFO)


class System(enum.Enum):
    WINDOWS = "windows"
    LINUX = "linux"
    MAC_ARM = "macos_arm64"
    MAC_INTEL = "macos_x86_64"

    @staticmethod
    def get_system():
        system = platform.system()
        if system == "Windows":
            return System.WINDOWS
        elif system == "Linux":
            return System.LINUX
        elif system == "Darwin":
            if platform.machine() == "arm64":
                return System.MAC_ARM
            else:
                return System.MAC_INTEL
        else:
            raise Exception("Unknown system")


def get_all_files(pattern: str, in_folder: str = ".") -> List[str]:
    files = glob.glob(path.join(in_folder, pattern), recursive=True)
    # unique files
    files = list(set(files))
    return files


def compress(files: List[str]):
    assert len(files) > 0
    current_system = System.get_system().value
    with zipfile.ZipFile(f"{current_system}.zip", "w") as zip:
        for file in files:
            base_name = path.basename(file)
            logging.info(f"Compressing {file}")
            zip.write(file, arcname=base_name)


if __name__ == '__main__':
    # get ext from args
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("--pattern", type=str, required=True)
    arg_parser.add_argument("--folder", type=str, default=".")

    args = arg_parser.parse_args()
    pattern = args.pattern
    in_folder = args.folder

    # get all files with ext
    files = get_all_files(pattern=pattern, in_folder=in_folder)
    logging.info(f"Found {len(files)} files with pattern {pattern}")
    # compress files
    compress(files)
