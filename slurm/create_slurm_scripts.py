import postgres.status
import postgres.utils
import argparse
import os
import utils.s3
import sys

def is_nat(x):
    '''
    Checks that a value is a natural number.
    '''
    if int(x) > 0:
        return int(x)
    raise argparse.ArgumentTypeError('%s must be positive, non-zero' % x)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="MuTect2 CWL workflow SLURM script creator")
    required = parser.add_argument_group("Required input parameters")
    required.add_argument("--thread_count", help="Thread count", required=True)
    required.add_argument("--mem", help="Max mem for each node", required=True)
    required.add_argument("--refdir", help="Reference dir on node", required=True)
    required.add_argument("--s3dir", help="S3bin for uploading output files", required=True)
    required.add_argument("--block", help="Parallel block size", required=True)
    required.add_argument('--java_heap', help='Java heap mem', required=True)
    required.add_argument("--postgres_config", help="Path to postgres config file", required=True)
    required.add_argument("--outdir", default="./", help="Output directory for slurm scripts")
    required.add_argument("--pipeline", choices=['tumor_only', 'pon'], help="Calling mutect2 on tumor only calling or creating pon on normal", required=True)
    required.add_argument("--input_table", help="Postgres input table name", required=True)
    required.add_argument("--input_primary_id", default="id", help="Primary id for postgres input table")
    required.add_argument("--status_table", default="None", help="Postgres status table name")
    args = parser.parse_args()

    if not os.path.isdir(args.outdir):
        raise Exception("Cannot find output directory: %s" % args.outdir)

    if not os.path.isfile(args.postgres_config):
        raise Exception("Cannot find config file: %s" % args.postgres_config)
    upload_s3 = utils.s3.check_s3url(args.s3dir)
    if args.pipeline == 'pon':
        engine = postgres.utils.get_db_engine(args.postgres_config)
        cases = postgres.status.get_pon_case(engine, str(args.input_table), str(args.status_table), input_primary_column=str(args.input_primary_id))
        for case in cases:
            normal_s3 = utils.s3.check_s3url(cases[case][3])
            slurm = open(os.path.join(args.outdir, "%s.%s.sh" %(args.pipeline, cases[case][1])), "w")
            template = os.path.join(os.path.dirname(os.path.realpath(__file__)),
            "etc/template.sh")
            temp = open(template, "r")
            for line in temp:
                if "XX_THREAD_COUNT_XX" in line:
                    line = line.replace("XX_THREAD_COUNT_XX", str(args.thread_count))
                if "XX_MEM_XX" in line:
                    line = line.replace("XX_MEM_XX", str(args.mem))
                if "XX_CASEID_XX" in line:
                    line = line.replace("XX_CASEID_XX", str(cases[case][0]))
                if "XX_TID_XX" in line:
                    line = line.replace("XX_TID_XX", "None")
                if "XX_NID_XX" in line:
                    line = line.replace("XX_NID_XX", str(cases[case][1]))
                if "XX_FILESIZE_XX" in line:
                    line = line.replace("XX_FILESIZE_XX", str(cases[case][2]))
                if "XX_TS3URL_XX" in line:
                    line = line.replace("XX_TS3URL_XX", "None")
                if "XX_TUMOR_BARCODE_XX" in line:
                    line = line.replace("XX_TUMOR_BARCODE_XX", "None")
                if "XX_TS3PROFILE_XX" in line:
                    line = line.replace("XX_TS3PROFILE_XX", "None")
                if "XX_TS3ENDPOINT_XX" in line:
                    line = line.replace("XX_TS3ENDPOINT_XX", "None")
                if "XX_NS3URL_XX" in line:
                    line = line.replace("XX_NS3URL_XX", normal_s3['s3url'])
                if "XX_NORMAL_BARCODE_XX" in line:
                    line = line.replace("XX_NORMAL_BARCODE_XX", str(cases[case][4]))
                if "XX_NS3PROFILE_XX" in line:
                    line = line.replace("XX_NS3PROFILE_XX", normal_s3['profile'])
                if "XX_NS3ENDPOINT_XX" in line:
                    line = line.replace("XX_NS3ENDPOINT_XX", normal_s3['endpoint'])
                if "XX_PIPELINE_XX" in line:
                    line = line.replace("XX_PIPELINE_XX", args.pipeline)
                if "XX_REFDIR_XX" in line:
                    line = line.replace("XX_REFDIR_XX", args.refdir)
                if "XX_S3DIR_XX" in line:
                    line = line.replace("XX_S3DIR_XX", upload_s3['s3url'])
                if "XX_S3PROFILE_XX" in line:
                    line = line.replace("XX_S3PROFILE_XX", upload_s3['profile'])
                if "XX_S3ENDPOINT_XX" in line:
                    line = line.replace("XX_S3ENDPOINT_XX", upload_s3['endpoint'])
                if "XX_BLOCKSIZE_XX" in line:
                    line = line.replace("XX_BLOCKSIZE_XX", str(args.block))
                if "XX_JAVAHEAP_XX" in line:
                    line = line.replace("XX_JAVAHEAP_XX", args.java_heap)
                if "XX_CWL_XX" in line:
                    line = line.replace("XX_CWL_XX", "tools/gatk4_mutect2.cwl")
                slurm.write(line)
            slurm.close()
            temp.close()
    elif args.pipeline == 'tumor_only':
        engine = postgres.utils.get_db_engine(args.postgres_config)
        cases = postgres.status.get_mutect2_case(engine, str(args.input_table), str(args.status_table), input_primary_column=str(args.input_primary_id))
        for case in cases:
            tumor_s3_url = utils.s3.get_s3url(str(cases[case][1]))
            tumor_s3 = utils.s3.check_s3url(tumor_s3_url)
            slurm = open(os.path.join(args.outdir, "%s.%s.sh" %(args.pipeline, cases[case][1])), "w")
            template = os.path.join(os.path.dirname(os.path.realpath(__file__)),
            "etc/template.sh")
            temp = open(template, "r")
            for line in temp:
                if "XX_THREAD_COUNT_XX" in line:
                    line = line.replace("XX_THREAD_COUNT_XX", str(args.thread_count))
                if "XX_MEM_XX" in line:
                    line = line.replace("XX_MEM_XX", str(args.mem))
                if "XX_CASEID_XX" in line:
                    line = line.replace("XX_CASEID_XX", str(cases[case][0]))
                if "XX_TID_XX" in line:
                    line = line.replace("XX_TID_XX", str(cases[case][1]))
                if "XX_NID_XX" in line:
                    line = line.replace("XX_NID_XX", str(cases[case][2]))
                if "XX_FILESIZE_XX" in line:
                    line = line.replace("XX_FILESIZE_XX", "None")
                if "XX_TS3URL_XX" in line:
                    line = line.replace("XX_TS3URL_XX", tumor_s3['s3url'])
                if "XX_TUMOR_BARCODE_XX" in line:
                    line = line.replace("XX_TUMOR_BARCODE_XX", str(cases[case][5]))
                if "XX_TS3PROFILE_XX" in line:
                    line = line.replace("XX_TS3PROFILE_XX", tumor_s3['profile'])
                if "XX_TS3ENDPOINT_XX" in line:
                    line = line.replace("XX_TS3ENDPOINT_XX", tumor_s3['endpoint'])
                if "XX_NS3URL_XX" in line:
                    line = line.replace("XX_NS3URL_XX", "None")
                if "XX_NORMAL_BARCODE_XX" in line:
                    line = line.replace("XX_NORMAL_BARCODE_XX", "None")
                if "XX_NS3PROFILE_XX" in line:
                    line = line.replace("XX_NS3PROFILE_XX", "None")
                if "XX_NS3ENDPOINT_XX" in line:
                    line = line.replace("XX_NS3ENDPOINT_XX", "None")
                if "XX_PIPELINE_XX" in line:
                    line = line.replace("XX_PIPELINE_XX", args.pipeline)
                if "XX_REFDIR_XX" in line:
                    line = line.replace("XX_REFDIR_XX", args.refdir)
                if "XX_S3DIR_XX" in line:
                    line = line.replace("XX_S3DIR_XX", upload_s3['s3url'])
                if "XX_S3PROFILE_XX" in line:
                    line = line.replace("XX_S3PROFILE_XX", upload_s3['profile'])
                if "XX_S3ENDPOINT_XX" in line:
                    line = line.replace("XX_S3ENDPOINT_XX", upload_s3['endpoint'])
                if "XX_BLOCKSIZE_XX" in line:
                    line = line.replace("XX_BLOCKSIZE_XX", str(args.block))
                if "XX_JAVAHEAP_XX" in line:
                    line = line.replace("XX_JAVAHEAP_XX", args.java_heap)
                if "XX_CWL_XX" in line:
                    line = line.replace("XX_CWL_XX", "workflows/gatk4_mutect2_single_tumor_calling.cwl")
                slurm.write(line)
            slurm.close()
            temp.close()
    else:
        raise Exception("Cannot get correct pipeline: %s. Please choose between 'mutect2' or 'pon'." % args.pipeline)
