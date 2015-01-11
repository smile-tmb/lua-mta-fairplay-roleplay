import os
import sys

def get_filelist( rootdir ):
  fileList = [ ]
  for root, subFolders, files in os.walk( rootdir ):
    for file in files:
      fileName = os.path.join( root, file )
      if os.path.splitext( fileName )[ 1 ] == ".lua": fileList.append( fileName )
  return fileList

def file_len( fname ):
  count = 0
  for line in open( fname ).readlines( ): count += 1
  return count

files = get_filelist( os.getcwd( ) )
total_len = 0

for file in files:
  try:
    flen = file_len( file )
    total_len += flen
    print( "{0} {1}".format( file, flen ) )
  except ValueError:
    print( "..." )

print( "{0}".format( total_len ) )

input( )
exit