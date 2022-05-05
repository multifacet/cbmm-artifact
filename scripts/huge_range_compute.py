#!/usr/bin/env python3

from sys import argv, exit

if len(argv) < 4:
    print("USAGE: ./script range_start range_end nslices")
    exit(-1)

range_start = int(argv[1], 16)
range_end = int(argv[2], 16)
nslices = int(argv[3])

# Need to round range_start/end to huge pages, expanding out.
range_start = (range_start >> 21) << 21
range_end = range_end if range_end % (1<<21) == 0 else ((range_end >> 21) + 1) << 21

range_size = (range_end - range_start) >> 21
even_slices = range_size % nslices == 0 
slice_size = range_size // nslices if even_slices else range_size // (nslices - 1)

print("Range is %s - %s, %d GB" % (hex(range_start), hex(range_end), range_size >> 9))
print("Using %d slices of size %d huge pages%s" % (nslices, slice_size,
    "" if even_slices else ", with the last being smaller"))

boundaries = [hex(range_start + (i+1) * (slice_size << 21)) for i in range(nslices)]

print(",".join(boundaries))

print()

boundaries = ["0x0"] + boundaries
ranges = ["%s %s" % r for r in zip(boundaries[:-1], boundaries[1:])]

print(",".join(ranges))
