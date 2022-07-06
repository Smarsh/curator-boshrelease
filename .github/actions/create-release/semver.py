import sys

version = sys.argv[1].split('.')

patch = int(version.pop()) + 1

version.append(str(patch))

separator = '.'
print(separator.join(version))
