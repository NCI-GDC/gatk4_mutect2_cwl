#!/usr/bin/env python
'''Internal multithreading GATK4 MuTect2 tumor only calling'''

import argparse
import subprocess
import string
from functools import partial
from multiprocessing.dummy import Pool, Lock

def is_nat(pos):
    '''Checks that a value is a natural number.'''
    if int(pos) > 0:
        return int(pos)
    raise argparse.ArgumentTypeError('{} must be positive, non-zero'.format(pos))

def do_pool_commands(cmd, lock=Lock(), shell_var=True):
    '''run pool commands'''
    try:
        output = subprocess.Popen(cmd, shell=shell_var, \
                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output_stdout, output_stderr = output.communicate()
        with lock:
            print 'running: {}'.format(cmd)
            print output_stdout
            print output_stderr
    except BaseException:
        print "command failed {}".format(cmd)
    return output.wait()

def multi_commands(cmds, thread_count, shell_var=True):
    '''run commands on number of threads'''
    pool = Pool(int(thread_count))
    output = pool.map(partial(do_pool_commands, shell_var=shell_var), cmds)
    return output

def get_region(intervals):
    '''get region from intervals'''
    interval_list = []
    with open(intervals, 'r') as fhandle:
        line = fhandle.readlines()
        for bed in line:
            blocks = bed.rstrip().rsplit('\t')
            intv = '{}:{}-{}'.format(blocks[0], int(blocks[1])+1, blocks[2])
            interval_list.append(intv)
    return interval_list

def cmd_template(cmd_dict, interval_list):
    '''cmd template'''
    cmd = [
        'java',
        '-Djava.io.tmpdir=/tmp/job_tmp_${BLOCK_NUM}',
        '-d64',
        '-jar',
        '-Xmx${JAVA_HEAP}',
        '-XX:+UseSerialGC',
        '${GATK_PATH}',
        'Mutect2',
        '-R',
        '${REF}',
        '-L',
        '${REGION}',
        '-I',
        '${TUMOR_BAM}',
        '-O',
        '${BLOCK_NUM}.mt2.vcf',
        '-tumor',
        '${TUMOR_SAMPLE}',
        '--af-of-alleles-not-in-resource',
        '${AF}',
        '--germline-resource',
        '${GR}',
        '-pon',
        '${PON}'
    ]
    cmd_str = ' '.join(cmd)
    if not cmd_dict['normal_bam']:
        if not cmd_dict['mode']:
            template = string.Template(cmd_str)
        else:
            cmd_str += " --dont-use-soft-clipped-bases"
            template = string.Template(cmd_str)
    else:
        cmd_str += " -I ${NORMAL_BAM} --normal ${NORMAL_SAMPLE}"
        if not cmd_dict['mode']:
            template = string.Template(cmd_str)
        else:
            cmd_str += " --dont-use-soft-clipped-bases"
            template = string.Template(cmd_str)
    for i, interval in enumerate(interval_list):
        cmd = template.substitute(
            dict(
                BLOCK_NUM=i,
                JAVA_HEAP=cmd_dict['java_heap'],
                GATK_PATH=cmd_dict['gatk_path'],
                REF=cmd_dict['ref'],
                REGION=interval,
                TUMOR_BAM=cmd_dict['tumor_bam'],
                TUMOR_SAMPLE=cmd_dict['tumor_sample'],
                NORMAL_BAM=cmd_dict['normal_bam'],
                NORMAL_SAMPLE=cmd_dict['normal_sample'],
                PON=cmd_dict['pon'],
                AF=cmd_dict['af'],
                GR=cmd_dict['gr']
            )
        )
        yield cmd, '{}.mt2.vcf'.format(i)

def main():
    '''main'''
    parser = argparse.ArgumentParser('Internal multithreading GATK4 MuTect2 tumor only calling.')
    # Required flags.
    parser.add_argument('-j', \
                        '--java_heap', \
                        required=True, \
                        help='Java heap memory.')
    parser.add_argument('-f', \
                        '--reference_path', \
                        required=True, \
                        help='Reference path.')
    parser.add_argument('-r', \
                        '--interval_bed_path', \
                        required=True, \
                        help='Interval bed file.')
    parser.add_argument('-t', \
                        '--tumor_bam', \
                        required=True, \
                        help='Tumor bam file.')
    parser.add_argument('-ts', \
                        '--tumor_sample', \
                        required=True, \
                        help='BAM sample name of tumor.')
    parser.add_argument('-n', \
                        '--normal_bam', \
                        required=False, \
                        help='Normal bam file.')
    parser.add_argument('-ns', \
                        '--normal_sample', \
                        required=False, \
                        help='BAM sample name of normal.')
    parser.add_argument('-c', \
                        '--thread_count', \
                        type=is_nat, \
                        required=True, \
                        help='Number of thread.')
    parser.add_argument('-p', \
                        '--pon', \
                        required=False, \
                        help='Panel of normals reference path.')
    parser.add_argument('-af', \
                        '--af_not_in_gr', \
                        required=False, \
                        help='Population allele fraction assigned \
                        to alleles not found in germline resource. \
                        A reasonable value is 1/(2* number of samples in resource) \
                        if a germline resource is available; \
                        otherwise an average heterozygosity rate such as 0.001 is reasonable.')
    parser.add_argument('-gr', \
                        '--germline_resource', \
                        required=False, \
                        help='Population vcf of germline sequencing containing allele fractions.')
    parser.add_argument('-m', \
                        '--dontUseSoftClippedBases', \
                        action="store_true", \
                        help='If specified, it will not analyze soft clipped bases in the reads.')
    args = parser.parse_args()
    input_dict = {
        'java_heap': args.java_heap,
        'ref': args.reference_path,
        'tumor_bam': args.tumor_bam,
        'tumor_sample': args.tumor_sample,
        'normal_bam': args.normal_bam,
        'normal_sample': args.normal_sample,
        'pon': args.pon,
        'af': args.af_not_in_gr,
        'gr': args.germline_resource,
        'mode': args.dontUseSoftClippedBases,
        'gatk_path': '/bin/gatk-4.0.4.0/gatk-package-4.0.4.0-local.jar'
    }
    interval_list = get_region(args.interval_bed_path)
    threads = args.thread_count
    mutect2_cmds = []
    mutect2_outs = []
    for i in list(cmd_template(input_dict, interval_list)):
        mutect2_cmds.append(i[0])
        mutect2_outs.append(i[1])
    outputs = multi_commands(mutect2_cmds, threads)
    if any(x != 0 for x in outputs):
        print 'Failed multi_gatk4_mutect2_calling'
    else:
        print 'Completed multi_gatk4_mutect2_calling'
        first = True
        with open('merged_multi_gatk4_mutect2_calling.vcf', 'w') as ohandle:
            for out in mutect2_outs:
                with open(out) as fhandle:
                    for line in fhandle:
                        if first or not line.startswith('#'):
                            ohandle.write(line)
                first = False

if __name__ == '__main__':
    main()
