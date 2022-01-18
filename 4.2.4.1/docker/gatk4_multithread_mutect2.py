import argparse
import os
import subprocess
import string
from functools import partial
from multiprocessing.dummy import Pool, Lock

def get_args():
    '''
    Loads the parser
    '''
    parser = argparse.ArgumentParser(prog='GATK4.2.4.1 Mutect2 multithreading wrapper.', add_help=True)
    required = parser.add_argument_group('Required input parameter')
    required.add_argument('-I', \
                          '--input', \
                          required=True, \
                          action='append', \
                          help='BAM files.')
    required.add_argument('-O', \
                          '--output', \
                          required=True, \
                          help='Output prefix on files to which variants should be written.')
    required.add_argument('-R', \
                          '--reference', \
                          required=True, \
                          help='Reference sequence file.')
    required.add_argument('--intervals', required=True, help='One or more genomic intervals over which to operate')
    required.add_argument('--java_heap', required=False, help='JVM arguments to GATK. This is NOT a GATK parameter.')
    required.add_argument('--nthreads', required=False, help='Number of threads used for this wrapper code. This is NOT a GATK parameter.')
    optional = parser.add_argument_group('Optional input parameter')
    optional.add_argument('--active-probability-threshold', required=False, help='Minimum probability for a locus to be considered active.')
    optional.add_argument('--adaptive-pruning-initial-error-rate', required=False, help='Initial base error rate estimate for adaptive pruning.')
    optional.add_argument('--af-of-alleles-not-in-resource', required=False, help='Population allele fraction assigned to alleles not found in germline resource. Please see docs/mutect/mutect2.pdf fora derivation of the.')
    optional.add_argument('--allow-non-unique-kmers-in-ref', required=False, help='Allow graphs that have non-unique kmers in the reference.', action='store_true')
    optional.add_argument('--assembly-region-padding', required=False, help='Number of additional bases of context to include around each assembly region.')
    optional.add_argument('--bam-output', required=False, help='If specified, assembled haplotypes wil be written to bam.', action='store_true')
    optional.add_argument('--bam-writer-type', required=False, help='Which haplotypes should be written to the BAM.')
    optional.add_argument('--base-quality-score-threshold', required=False, help='Base qualities below this threshold will be reduced to the minimum (6).')
    optional.add_argument('--callable-depth', required=False, help='Minimum depth to be considered callable for Mutect stats. Does not affect genotyping.')
    optional.add_argument('--disable-adaptive-pruning', required=False, help='Disable the adaptive algorithm for pruning paths in the graph.', action='store_true')
    optional.add_argument('--disable-bam-index-caching', required=False, help='If true, dont cache bam indexes, this will reduce memory requirements but may harm performance if many intervals are specified. Caching is automatically disabled if there are no intervals specified.', action='store_true')
    optional.add_argument('--disable-sequence-dictionary-validation', required=False, help='If specified, do not check the sequence dictionaries from our inputs for compatibility. Use at your own risk!', action='store_true')
    optional.add_argument('--disable-tool-default-annotations', required=False, help='Disable all tool default annotations.', action='store_true')
    optional.add_argument('--dont-increase-kmer-sizes-for-cycles', required=False, help='Disable iterating over kmer sizes when graph cycles are detected.', action='store_true')
    optional.add_argument('--dont-trim-active-regions', required=False, help='If specified, we will not trim down the active region from the full region (active + extension) to just the active interval for genotyping.', action='store_true')
    optional.add_argument('--dont-use-soft-clipped-bases', required=False, help='Do not analyze soft clipped bases in the reads.', action='store_true')
    optional.add_argument('--downsampling-stride', required=False, help='Downsample a pool of reads starting within a range of one or more bases.')
    optional.add_argument('--emit-ref-confidence', required=False, help='(BETA feature) Mode for emitting reference confidence scores.')
    optional.add_argument('--enable-all-annotations', required=False, help='Use all possible annotations (not for the faint of heart).', action='store_true')
    optional.add_argument('--f1r2-max-depth', required=False, help='Sites with depth higher than this value will be grouped.')
    optional.add_argument('--f1r2-median-mq', required=False, help='Skip sites with median mapping quality below this value.')
    optional.add_argument('--f1r2-min-bq', required=False, help='Exclude bases below this quality from pileup.')
    optional.add_argument('--f1r2-tar-gz', required=False, help='If specified, collect F1R2 counts and output files into tar.gz file.', action='store_true')
    optional.add_argument('--force-active', required=False, help='If provided, all regions will be marked as active.', action='store_true')
    optional.add_argument('--genotype-filtered-alleles', required=False, help='Whether to force genotype even filtered alleles.', action='store_true')
    optional.add_argument('--genotype-germline-sites', required=False, help='(EXPERIMENTAL) Call all apparent germline site even though they will ultimately be filtered.', action='store_true')
    optional.add_argument('--genotype-pon-sites', required=False, help='Call sites in the PoN even though they will ultimately be filtered.', action='store_true')
    optional.add_argument('--germline-resource', required=False, help='Population vcf of germline sequencing containing allele fractions.')
    optional.add_argument('--gvcf-lod-band', required=False, help='Exclusive upper bounds for reference confidence LOD bands (must be specified in increasing order).')
    optional.add_argument('--ignore-itr-artifacts', required=False, help='Turn off read transformer that clips artifacts associated with end repair insertions near inverted tandem repeats.', action='store_true')
    optional.add_argument('--initial-tumor-lod', required=False, help='Log 10 odds threshold to consider pileup active.')
    optional.add_argument('--interval-merging-rule', required=False, help='Interval merging rule for abutting intervals.')
    optional.add_argument('--kmer-size', required=False, help='Kmer size to use in the read threading assembler.')
    optional.add_argument('--max-assembly-region-size', required=False, help='Maximum size of an assembly region.')
    optional.add_argument('--max-mnp-distance', required=False, help='Two or more phased substitutions separated by this distance or less are merged into MNPs.')
    optional.add_argument('--max-num-haplotypes-in-population', required=False, help='Maximum number of haplotypes to consider for your population.')
    optional.add_argument('--max-population-af', required=False, help='Maximum population allele frequency in tumor-only mode.')
    optional.add_argument('--max-prob-propagation-distance', required=False, help='Upper limit on how many bases away probability mass can be moved around when calculating the boundaries between active and inactive assembly regions.')
    optional.add_argument('--max-reads-per-alignment-start', required=False, help='Maximum number of reads to retain per alignment start position. Reads above this threshold will be downsampled. Set to 0 to disable.')
    optional.add_argument('--max-suspicious-reads-per-alignment-start', required=False, help='Maximum number of suspicious reads (mediocre mapping quality or too many substitutions) allowed in a downsampling stride. Set to 0 to disable.')
    optional.add_argument('--max-unpruned-variants', required=False, help='Maximum number of variants in graph the adaptive pruner will allow.')
    optional.add_argument('--min-assembly-region-size', required=False, help='Minimum size of an assembly region.')
    optional.add_argument('--min-base-quality-score', required=False, help='Minimum base quality required to consider a base for calling.')
    optional.add_argument('--min-dangling-branch-length', required=False, help='Minimum length of a dangling branch to attempt recovery.')
    optional.add_argument('--min-pruning', required=False, help='Minimum support to not prune paths in the graph.')
    optional.add_argument('--minimum-allele-fraction', required=False, help='Lower bound of variant allele fractions to consider when calculating variant LOD.')
    optional.add_argument('--mitochondria-mode', required=False, help='Mitochondria mode sets emission and initial LODs to 0.', action='store_true')
    optional.add_argument('--native-pair-hmm-threads', required=False, help='How many threads should a native pairHMM implementation use.')
    optional.add_argument('--native-pair-hmm-use-double-precision', required=False, help='Use double precision in the native pairHmm. This is slower but matches the java implementation better.', action='store_true')
    optional.add_argument('--normal-lod', required=False, help='Log 10 odds threshold for calling normal variant non-germline.')
    optional.add_argument('--normal-sample', required=False, help='BAM sample name of normal(s), if any. May be URL-encoded as output by GetSampleName with -encode argument.')
    optional.add_argument('--num-pruning-samples', required=False, help='Number of samples that must pass the minPruning threshold.')
    optional.add_argument('--pair-hmm-gap-continuation-penalty', required=False, help='Flat gap continuation penalty for use in the Pair HMM.')
    optional.add_argument('--pair-hmm-implementation', required=False, help='The PairHMM implementation to use for genotype likelihood calculations.')
    optional.add_argument('--panel-of-normals', required=False, help='VCF file of sites observed in normal.')
    optional.add_argument('--pcr-indel-model', required=False, help='The PCR indel model to use.')
    optional.add_argument('--pcr-indel-qual', required=False, help='Phred-scaled PCR SNV qual for overlapping fragments.')
    optional.add_argument('--pcr-snv-qual', required=False, help='Phred-scaled PCR SNV qual for overlapping fragments.')
    optional.add_argument('--pedigree', required=False, help='Pedigree file for determining the population "founders".')
    optional.add_argument('--phred-scaled-global-read-mismapping-rate', required=False, help='The global assumed mismapping rate for reads.')
    optional.add_argument('--pruning-lod-threshold', required=False, help='Ln likelihood ratio threshold for adaptive pruning algorithm.')
    optional.add_argument('--recover-all-dangling-branches', required=False, help='Recover all dangling branches.', action='store_true')
    optional.add_argument('--showHidden', required=False, help='Display hidden arguments.', action='store_true')
    optional.add_argument('--sites-only-vcf-output', required=False, help='If true, dont emit genotype fields when writing vcf file output.', action='store_true')
    optional.add_argument('--smith-waterman', required=False, help='Which Smith-Waterman implementation to use, generally FASTEST_AVAILABLE is the right choice.')
    optional.add_argument('--tumor-lod-to-emit', required=False, help='Log 10 odds threshold to emit variant to VCF.')
    return parser.parse_args()

def key_to_cmd(string):
    '''
    translate key to cmd
    string: xx_xx_xx
    returns: --xx-xx-xx
    '''
    return '--{}'.format(string.replace('_', '-'))

def prepare_cmd_args(args):
    '''
    prepare GATK4.2.4.1 Mutect2 cmd based on the python parameters.
    args: parser.parse_args()
    returns: An argument file for the gatk command
    '''
    arg_file = 'argument_file'
    exclude = ['output', 'f1r2_tar_gz', 'bam_output', 'intervals','nthreads', 'java_heap']
    dct = vars(args)
    cmds = list()
    for k, v in dct.items():
        if k not in exclude:
            if v is not None and v is not False:
                if v is True:
                    cmds.append('{}'.format(key_to_cmd(k)))
                elif isinstance(v, str) or isinstance(v, int) or isinstance(v, float):
                    cmds.append('{} {}'.format(key_to_cmd(k), str(v)))
                elif isinstance(v, list):
                    for i in v:
                        cmds.append('{} {}'.format(key_to_cmd(k), i))
    with open(arg_file, 'w') as of:
        for arg in cmds:
            of.writelines(arg + '\n')
    return {
        'output_prefix': args.output,
        'intervals': args.intervals,
        'f1r2': args.f1r2_tar_gz,
        'bamout': args.bam_output,
        'nthreads': args.nthreads,
        'java_heap': args.java_heap,
        'arg_file': os.path.abspath(arg_file),
        'gatk4': '/usr/local/bin/gatk.jar'
    }

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

def cmd_template(params):
    '''cmd template
    params: dict from prepare_cmd_args
    '''
    template = string.Template(
        "${GATK_PATH} --java-options \"-XX:+UseSerialGC -Xmx${JAVA_HEAP}\" Mutect2 --intervals ${REGION} --arguments_file ${ARGS} --output ${OUTPUT}.${BLOCK_NUM}.vcf.gz"
    )
    for i, interval in enumerate(get_region(params['intervals'])):
        cmd = template.substitute(
            dict(
                JAVA_HEAP=params['java_heap'],
                GATK_PATH=params['gatk4'],
                REGION=interval,
                ARGS=params['arg_file'],
                OUTPUT=params['output_prefix'],
                BLOCK_NUM=i
            )
        )
        if params['f1r2']:
            cmd += ' --f1r2-tar-gz {}.{}.tar.gz'.format(params['output_prefix'], i)
        if params['bamout']:
            cmd += ' --bam-output {}.{}.reassembly.bam'.format(params['output_prefix'], i)
        yield cmd

def main():
    '''main'''
    params = prepare_cmd_args(get_args())
    cmds = list(cmd_template(params))
    ec = multi_commands(cmds, params['nthreads'])
    if any(x != 0 for x in ec):
        print('Failed GATK4.2.4.1 multithreading Mutect2 calling.')
    else:
        print('Completed.')

if __name__ == "__main__":
    main()

