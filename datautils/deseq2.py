import os
import subprocess

import pandas as pd

from datautils.rscript_runner import RScriptRunner

__FILEPATH__ = os.path.abspath(os.path.dirname(__file__))

class DESeq2Normalization(RScriptRunner):

    SCRIPT = os.path.join(__FILEPATH__, 'deseq2_normalize.R')

    @classmethod
    def run(cls,
            count_df,
            coldata=None,
            design='~ 1',
            row_sum_cutoff=-1,
            num_cores=4,
            verbose=False,
            rscript_binary=None):
        '''

        '''
        if rscript_binary is None:
            rscript_binary = cls.RSCRIPT
        count_matrix = '.biographkernels_deseq2_count_matrix.csv.gz'
        count_df.to_csv(count_matrix, compression='gzip', index=True, index_label='id')
        _coldata = '.biographkernels_deseq2_coldata.csv.gz'
        if coldata is None:
            coldata = pd.DataFrame({'sample': list(count_df.columns), 'condition': len(count_df.columns) * ['x']})
        coldata.to_csv(_coldata, compression='gzip')
        output_file = '.biographkernels_deseq2_result.csv.gz'
        call = [rscript_binary,
                cls.SCRIPT,
                '--count-matrix=%s' % count_matrix,
                '--coldata=%s' % _coldata,
                '--design="%s"' % design,
                '--row-sum-cutoff=%d' % row_sum_cutoff,
                '--num-cores=%d' % num_cores,
                '--output-file=%s' % output_file,
                '--path-of-script=%s' % __FILEPATH__]
        if verbose:
            call.append('--verbose')
        subprocess.run(call, check=True)
        ret = pd.read_table(output_file, sep=',', compression='gzip', index_col=0)
        subprocess.run(['rm', count_matrix])
        subprocess.run(['rm', _coldata])
        subprocess.run(['rm', output_file])
        return ret

class DESeq2DEAnalysis(RScriptRunner):
    pass
