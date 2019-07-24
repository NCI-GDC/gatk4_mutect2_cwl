"""
Modify GATK4.1.2 Mutect2 VCF sample header to "TUMOR", "NORMAL"

@author: Shenglai Li
"""
import os
import pysam
import argparse

def get_args():
    '''
    Load the parser
    '''
    parser = argparse.ArgumentParser(prog='Modify GATK4.1.2 Mutect2 VCF sample header', add_help=True)
    parser.add_argument('--tumor_bam', required=True)
    parser.add_argument('--normal_bam', required=False)
    parser.add_argument('--vcf', required=True)
    parser.add_argument('--output', required=True)
    return parser.parse_args()

def get_sample_name(bam):
    '''
    Get sample name from BAM file
    '''
    b = pysam.AlignmentFile(bam, 'rb')
    sample = b.header['RG'][0]['SM']
    return sample

def modify_vcf_sample(t, n, vcf, output):
    '''
    Modify VCF sample in the header
    '''
    out_vcf = output
    reader = pysam.BGZFile(vcf, mode='rb')
    writer = pysam.BGZFile(out_vcf, mode='wb')
    try:
        for line in reader:
            line = line.decode('utf-8')
            if line.startswith('#CHROM'):
                if n:
                    assert n in line, 'Unable to find normal sample tag in the vcf file. {0}'.format(n)
                    new_line = line.replace('{}\t{}'.format(n, t), 'NORMAL\tTUMOR')
                else:
                    assert t in line, 'Unable to find tumor sample tag in the vcf file. {0}'.format(t)
                    new_line = line.replace('{}'.format(t), 'TUMOR')
                new_line = new_line + '\n'
                writer.write(new_line.encode('utf-8'))
            else:
                new_line = line + '\n'
                writer.write(new_line.encode('utf-8'))
    finally:
        writer.close()
        reader.close()
    pysam.tabix_index(out_vcf, preset='vcf', force=True)

def main():
    '''
    main
    '''
    args = get_args()
    tumor_sample = get_sample_name(args.tumor_bam)
    normal_sample = None
    if args.normal_bam:
        normal_sample = get_sample_name(args.normal_bam)
    modify_vcf_sample(tumor_sample, normal_sample, args.vcf, args.output)

if __name__ == "__main__":
    main()