import os
import subprocess

import pandas as pd

from datautils.rscript_runner import RScriptRunner

__FILEPATH__ = os.path.abspath(os.path.dirname(__file__))

class TDMTransform(RScriptRunner):

    SCRIPT = os.path.join(__FILEPATH__, 'tdm_transform.R')

    @classmethod
    def run(cls,
            count_df,
            row_sum_cutoff=-1,
            normalize_method='quantile',
            verbose=False,
            rscript_binary=None):
        '''

        '''
        if rscript_binary is None:
            rscript_binary = cls.RSCRIPT
        count_matrix = '.biographkernels_count_matrix.csv.gz'
        count_df.to_csv(count_matrix, compression='gzip', index=True, index_label='id')
        output_file = '.biographkernels_result.csv.gz'
        call = [rscript_binary,
                cls.SCRIPT,
                '--count-matrix=%s' % count_matrix,
                '--row-sum-cutoff=%d' % row_sum_cutoff,
                '--normalize-method=%s' % normalize_method,
                '--output-file=%s' % output_file,
                '--path-of-script=%s' % __FILEPATH__]
        if verbose:
            call.append('--verbose')
        subprocess.run(call, check=True)
        ret = pd.read_table(output_file, sep=',', compression='gzip', index_col=0)
        subprocess.run(['rm', count_matrix])
        subprocess.run(['rm', output_file])
        return ret
