#!/bin/bash

# PERIODIC BOUNDARY CONDITIONS
# Here the atoms are connected only if periodic boundary conditions are considered
# The first calculation is done considering PBC. The other one is done using exactly the same configurations and command but addin just the following command: NOPBC

# Density of the cylinder inside the domain: 1.2732 => A SINGLE CLUSTER SHOULD BE DETECTED => 2 atoms in first cluster 0 in the second
# Density of the cylinder through the walls: 0.0 => TWO CLUSTERS SHOULD BE DETECTED => Each one with 1 atom

rm -f bck.* k
rm -f *~
rm -f Cluster_*.dat
rm -f plumed.dat
rm -f TEST_1.xyz

# Create the system to analize file TEST_1.xyz
touch TEST_1.xyz
echo '7'                       >> TEST_1.xyz
echo '7.0 1.0 1.0'             >> TEST_1.xyz
echo 'Ar   -3.0    0.0    0.0' >> TEST_1.xyz
echo 'Ar    3.0    0.0    0.0' >> TEST_1.xyz
echo 'Ne    0.0    0.0    0.0' >> TEST_1.xyz
echo 'Ne   -1.0    0.0    0.0' >> TEST_1.xyz
echo 'Ne   -2.0    0.0    0.0' >> TEST_1.xyz
echo 'Ne    1.0    0.0    0.0' >> TEST_1.xyz
echo 'Ne    2.0    0.0    0.0' >> TEST_1.xyz


# Create the correct result to compare with kk
rm -f Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 1 TH LARGEST CLUSTER EQUALS 2 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : 0 1 ' >> Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 2 TH LARGEST CLUSTER EQUALS 0 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : ' >> Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 1 TH LARGEST CLUSTER EQUALS 1 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : 1 ' >> Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 2 TH LARGEST CLUSTER EQUALS 1 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : 0 ' >> Correct_Result.dat


source /home/carles/Documents/mycodes/plumed2/sourceme.sh


echo "Running TEST-10"
echo "* Correct implementation of periodic boundary conditions"
rm -f kk.dat

#cp PLUMED_1_CLUSTER plumed.dat

rm -f plumed.dat
touch plumed.dat
echo 'mat: TOPOLOGY_MATRIX NODES=1-2 ATOMS=3-7 BIN_SIZE=1.0 CYLINDER_SWITCH={RATIONAL  D_0=0.0 R_0=0.001 D_MAX=0.002} SWITCH={RATIONAL D_0=10.0 R_0=1.0 D_MAX=12.0} RADIUS={RATIONAL D_0=0.5 R_0=0.000001 D_MAX=0.6} SIGMA=1.0 KERNEL=triangular DENSITY_THRESHOLD={RATIONAL D_0=0.5 R_0=0.1 D_MAX=0.7}' >> plumed.dat
echo 'DFSCLUSTERING MATRIX=mat LABEL=ss1' >> plumed.dat
echo ' ' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=1 FILE=Cluster_1.dat' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=2 FILE=Cluster_2.dat' >> plumed.dat

mpirun -np 1 plumed  driver --ixyz TEST_1.xyz > garbage
cat Cluster_1.dat  Cluster_2.dat  >> k

rm -f Cluster_*.dat


rm -f plumed.dat
touch plumed.dat
echo 'mat: TOPOLOGY_MATRIX NOPBC NODES=1-2 ATOMS=3-7 BIN_SIZE=1.0 CYLINDER_SWITCH={RATIONAL  D_0=0.0 R_0=0.001 D_MAX=0.002} SWITCH={RATIONAL D_0=10.0 R_0=1.0 D_MAX=12.0} RADIUS={RATIONAL D_0=0.5 R_0=0.000001 D_MAX=0.6} SIGMA=1.0 KERNEL=triangular DENSITY_THRESHOLD={RATIONAL D_0=0.5 R_0=0.1 D_MAX=0.7}' >> plumed.dat
echo 'DFSCLUSTERING MATRIX=mat LABEL=ss1' >> plumed.dat
echo ' ' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=1 FILE=Cluster_1.dat' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=2 FILE=Cluster_2.dat' >> plumed.dat


mpirun -np 1 plumed  driver --ixyz TEST_1.xyz > garbage
cat Cluster_1.dat  Cluster_2.dat  >> k

diff -b Correct_Result.dat k


#http://misc.flogisoft.com/bash/tip_colors_and_formatting
if diff -b Correct_Result.dat k >/dev/null ; then
  echo -e '\e[42m\e[97m    TEST-10    PASSED SUCCESSFULLY    \033[0m'
else
  echo -e '\e[41m\e[97m    TEST-10    FAILED    \033[0m'
fi
rm -f bck.* k
rm -f *~
rm -f Cluster_*.dat
rm -f plumed.dat
rm -f TEST_1.xyz
rm -f garbage
rm -f Correct_Result.dat
