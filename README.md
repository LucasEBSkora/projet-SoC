Projet pour le module de "Conception d'un Système sur Puce" du 3A de l'approfondissement SLE de Telecom Nancy

Le projet consiste d'un Processeur RISC-V simplifié.

Pour executer un testbench et voir les formes d'onde:

    make TESTBENCH=<nom de l'entité>

Pour executer un programme dans le dossier programs:

changer le chemin dans le fichier testbench/instruction_test_tb_.vhd

    make TESTBENCH=instruction_test

pour executer un tesbench sans voir les formes d'onde:

    make TESTBENCH=<nom de l'entité> test

pour executer tous les tests:

    ./testall.sh

[site web pour simuler l'assembly RISC-V](https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/)