
# Team3 Functional Annotation


## Dependencies
For all the tools below add the exectuables to your PATH environment variable.
- CD-HIT

  Visit the CD-HIT github page for the latest release: https://github.com/weizhongli/cdhit

  ```
  git clone https://github.com/weizhongli/cdhit.git
  cd cdhit/
  make
  ```
  
- eggNOG

  Visit the eggNOG installation page for more detailed instructions https://github.com/eggnogdb/eggnog-mapper/wiki/Installation. Note that the eggNOG databases are large around 70 GB.

  ```
  git clone https://github.com/jhcepas/eggnog-mapper.git
  cd eggnog-mapper
  ./download_eggnog_data.py bact
  ```

- Infernal and Rfam

  Infernal may be obtained from bioconda:

  ```
  conda install -c bioconda infernal=1.1.2
  ```

  To download the Rfam database, use the `dependencies/prepare_Rfam.sh` script.

  ```
  cd dependencies
  ./prepare_Rfam.sh
  cd ..
  ```

- InterProScan

  Follow the InterProScan installation steps at https://github.com/ebi-pf-team/interproscan/wiki/HowToDownload for detailed instructions and make sure to install the PANTHER database. 
  ```
  mkdir my_interproscan
  cd my_interproscan
  wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.33-72.0/interproscan-5.33-72.0-64-bit.tar.gz
  wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.33-72.0/interproscan-5.33-72.0-64-bit.tar.gz.md5
  tar -pxvzf interproscan-5.33-72.0-*-bit.tar.gz
  
  wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/data/panther-data-12.0.tar.gz
  wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/data/panther-data-12.0.tar.gz.md5
  md5sum -c panther-data-12.0.tar.gz.md5
  cd [InterProScan5 home]/data
  tar -pxvzf panther-data-12.0.tar.gz
  ```

- Phobius

  To download the phobius program, use the `dependencies/prepare_phobius.sh` script

  ```
  cd dependencies
  ./prepare_phobius.sh
  cd ..
  ```
  
  - CARD: 
  conda search --channel bioconda rgi
  conda install --channel bioconda rgi
  
