#!/usr/bin/env python
'''Internal multithreading GATK4 MuTect2 single tumor calling'''

import argparse
import subprocess
import string
from functools import partial
from multiprocessing.dummy import Pool, Lock

def is_nat(x):
    '''Checks that a value is a natural number.'''
    if int(x) > 0:
        return int(x)
    raise argparse.ArgumentTypeError('%s must be positive, non-zero' % x)

def do_pool_commands(cmd, lock=Lock(), shell_var=True):
    '''run pool commands'''
    try:
        output = subprocess.Popen(cmd, shell=shell_var, \
                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output_stdout, output_stderr = output.communicate()
        with lock:
            print('running: {}'.format(cmd))
            print(output_stdout)
            print(output_stderr)
    except Exception:
        print("command failed {}".format(cmd))
    return output.wait()

def multi_commands(cmds, thread_count, shell_var=True):
    '''run commands on number of threads'''
    pool = Pool(int(thread_count))
    output = pool.map(partial(do_pool_commands, shell_var=shell_var), cmds)
    return output

def get_region(intervals):
    '''get region from intervals'''
    interval_list = []
    with open(intervals, 'r') as fh:
        line = fh.readlines()
        for bed in line:
            blocks = bed.rstrip().rsplit('\t')
            intv = '{}:{}-{}'.format(blocks[0], int(blocks[1])+1, blocks[2])
            interval_list.append(intv)
    return interval_list

def cmd_template(java_heap, gatk_path, ref, region, tumor_bam, tumor_sample, pon, af, gr, mode):
    '''cmd template'''
    if not mode:
        template = string.Template("java -Djava.io.tmpdir=/tmp/job_tmp_${BLOCK_NUM} -d64 -jar -Xmx${JAVA_HEAP} -XX:+UseSerialGC ${GATK_PATH} Mutect2 -R ${REF} -L ${REGION} -I ${TUMOR_BAM} -O ${BLOCK_NUM}.mt2.vcf -tumor ${TUMOR_SAMPLE} --af-of-alleles-not-in-resource ${AF} --germline-resource ${GR} -pon ${PON}")
    else:
        template = string.Template("java -Djava.io.tmpdir=/tmp/job_tmp_${BLOCK_NUM} -d64 -jar -Xmx${JAVA_HEAP} -XX:+UseSerialGC ${GATK_PATH} Mutect2 -R ${REF} -L ${REGION} -I ${TUMOR_BAM} -O ${BLOCK_NUM}.mt2.vcf -tumor ${TUMOR_SAMPLE} --af-of-alleles-not-in-resource ${AF} --germline-resource ${GR} -pon ${PON} --dont-use-soft-clipped-bases")
    for i, interval in enumerate(region):
        cmd = template.substitute(
            dict(
                BLOCK_NUM=i,
                JAVA_HEAP=java_heap,
                GATK_PATH=gatk_path,
                REF=ref,
                REGION=interval,
                TUMOR_BAM=tumor_bam,
                TUMOR_SAMPLE=tumor_sample,
                PON=pon,
                AF=af,
                GR=gr
            )
        )
        yield cmd, '{}.mt2.vcf'.format(i)

def main():
    '''main'''
    parser = argparse.ArgumentParser('Internal multithreading GATK4 MuTect2 single tumor calling.')
    # Required flags.
    parser.add_argument('-j', '--java_heap', required=True, help='Java heap memory.')
    parser.add_argument('-f', '--reference_path', required=True, help='Reference path.')
    parser.add_argument('-r', '--interval_bed_path', required=True, help='Interval bed file.')
    parser.add_argument('-t', '--tumor_bam', required=True, help='Tumor bam file.')
    parser.add_argument('-ts', '--tumor_sample', required=True, help='BAM sample name of tumor. May be URL-encoded as output by GetSampleName with -encode argument.')
    parser.add_argument('-c', '--thread_count', type=is_nat, required=True, help='Number of thread.')
    parser.add_argument('-p', '--pon', required=True, help='Panel of normals reference path.')
    parser.add_argument('-af', '--af_not_in_gr', required=True, help='Population allele fraction assigned to alleles not found in germline resource. A reasonable value is 1/(2* number of samples in resource) if a germline resource is available; otherwise an average heterozygosity rate such as 0.001 is reasonable.')
    parser.add_argument('-gr', '--germline_resource', required=True, help='Population vcf of germline sequencing containing allele fractions.')
    parser.add_argument('-m', '--dontUseSoftClippedBases', action="store_true", help='If specified, it will not analyze soft clipped bases in the reads.')
    args = parser.parse_args()
    java_heap = args.java_heap
    ref = args.reference_path
    interval = args.interval_bed_path
    tumor = args.tumor_bam
    tumor_sample = args.tumor_sample
    threads = args.thread_count
    pon = args.pon
    af = args.af_not_in_gr
    gr = args.germline_resource
    mode = args.dontUseSoftClippedBases
    gatk_path = '/bin/gatk-4.0.4.0/gatk-package-4.0.4.0-local.jar'
    mutect2_cmds = list(cmd_template(java_heap, gatk_path, ref, get_region(interval), tumor, tumor_sample, pon, af, gr, mode))
    outputs = multi_commands(mutect2_cmds, threads)
    if any(x != 0 for x in outputs):
        print('Failed multi_gatk4_mutect2_single_tumor_calling')
    else:
        print('Completed multi_gatk4_mutect2_single_tumor_calling')
        first = True
        with open('merged_multi_gatk4_mutect2_single_tumor_calling.vcf', 'w') as oh:
            for cmd, out in mutect2_cmds:
                with open(out) as fh:
                    for line in fh:
                        if first or not line.startswith('#'):
                            oh.write(line)
                first = False

if __name__ == '__main__':
    main()
