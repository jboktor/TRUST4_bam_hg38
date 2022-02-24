version 1.1

task TRUST4bamhg38 {
    input {
      File bam
      String samplename
      Int thread
      Int stage
      Int runtime_memory
      Int runtime_preemptible = 3
      Float runtime_disk_multiplier = 5
      Int runtime_disk_gb = ceil(size(bam, 'GB') * runtime_disk_multiplier)
    }

    command {
        /home/TRUST4/run-trust4 -b ${bam} \
          -f /home/TRUST4/hg38_bcrtcr.fa --ref /home/TRUST4/human_IMGT+C.fa \
          -o ${samplename} \
          -t ${thread} \
          --stage ${stage}
    }

    output {
        File out_cdr3="${samplename}_cdr3.out"
        File trust4final="${samplename}_final.out"
        File trust4report="${samplename}_report.tsv"
    }

    runtime {
        disks: 'local-disk ${runtime_disk_gb} HDD'
        docker: "jemimalwh/trust4:0.2.0"
        memory: "${runtime_memory} GB"
        preemptible: '${runtime_preemptible}'
        bootDiskSizeGb: 10
    }

    meta {
        author: "Wenhui Li"
    }
}

workflow TRUST4workflow {
    input {
        File bam
        String samplename
        Int thread
        Int stage
        Int runtime_memory
    }

    call TRUST4bamhg38 { input: bam=bam, samplename=samplename, thread=thread, stage=stage, memory=runtime_memory }

    output {
        File out_cdr3 = TRUST4bamhg38.out_cdr3
        File trust4final = TRUST4bamhg38.trust4final
        File trust4report = TRUST4bamhg38.trust4report
    }
}
