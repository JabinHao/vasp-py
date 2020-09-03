#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Mar 21 00:19:17 2020

@author: hjp
"""

from pymatgen.analysis.ewald import EwaldSummation
#from pymatgen.analysis.energy_models import EwaldElectrostaticModel
from pymatgen.io.cif import CifParser, CifWriter
from pymatgen.io.vasp.inputs import Poscar

front_name = "disordering/disordering_0"
structures = []
Electrostatic_energy = []
for i in range(1,101):
    middle_name = front_name+"{:03d}".format(i)
    filename = middle_name + ".cif"
    parser = CifParser(filename)
    structure = parser.get_structures()[0]
    oxidation_state = {"Li":1, "Sr":2, "Ta":5, "Hf":4, "O":-2}
    structure.add_oxidation_state_by_element(oxidation_state)
    structures.append(structure)

for structure in structures:
    Electrostatic_energy.append(EwaldSummation(structure).total_energy)

indexs = sorted(range(len(Electrostatic_energy)), key=lambda k: Electrostatic_energy[k])
print(indexs)

i=1
for index in indexs:
    fc = "ordering/cif/{}.cif".format(i)
    fp = "ordering/poscar/{}.POSCAR.vasp".format(i)
    fe = "Electrostatic_energy.txt"
    # structure = structures[index]
    # CifWriter(structure).write_file(fc)
    # Poscar(structure).write_file(fp)
    with open(fe,'a+') as f:
        f.write("{:>3d}. {:.5f} eV\n".format(i, Electrostatic_energy[index]))
    i += 1

