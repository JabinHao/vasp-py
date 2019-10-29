# An Example script to generate VASP calculation files:
# for parameters used in each function, please search pymatgen website for details

import pymatgen                                       # To import the pymatgen module.

from pymatgen.io.cif import CifParser, CifWriter      # Import 2 functions to read CIF files.

from pymatgen import Structure                        # Structure is a function which describes material structure, 
                                                      # by which you can easily change a CIF file to POSCAR file.

from pymatgen.io.vasp.sets import MPRelaxSet          # A pymatgen function which generates VASP calculation files.
                                                      # The calculation file generated will be compatible with
                                                      # materialsproject website.

file_input = 'E:\\ehull\\peroviskate.\\CaTiO3_mp-5827_primitive.cif' # the input CIF file, which will be 'KAlCl4'

input_cif = CifParser(file_input, occupancy_tolerance=2.0) # read the input CIF file

input_structure = input_cif.get_structures(primitive = True)[0] # read the structure from CIF file
                                                                 # Note that 'input_structure' is a Structure object

incar_setting = {'ISPIN':2,'ICHARG':1,'NELM':100,'NELMIN':100,'IBRION':2,'EDIFF':2E-6,'ISIF':3,'LREAL':'AUTO','ISMEAR':-5,'SIGMA':0.05,'LWAVE':'true','ISYM': 0, 'NPAR': 1} # this is a custom setting. You may search ISYM and NPAR for VASP tags
                                       # NPAR is related to parallel computation. I set 1 here to avoid weird failure

input_set = MPRelaxSet(structure=input_structure, user_incar_settings=incar_setting) # pymatgen will generate all
                                                                                     # 4 files for you.
output_dir = 'E:/ehull/peroviskate./first_VASP/'

input_set.write_input(output_dir, make_dir_if_not_present=True)
# after this, you should be able to see a new directory in your folder, whose name is 'first_VASP', and there are 4
# files in it: INCAR, KPOINTS, POTcAR and POSCAR
# Then, your VASP calculation is ready to run.
