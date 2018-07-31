import os
import subprocess

import pandas as pd

from datautils.rscript_runner import RScriptRunner

__FILEPATH__ = os.path.abspath(os.path.dirname(__file__))

class QuantileNormalization(RScriptRunner):

    SCRIPT = os.path.join(__FILEPATH__, 'quantile_normalize.R')

    @classmethod
    def run(cls,
            df,
            verbose=False,
            rscript_binary=None):
        '''

        '''
        if rscript_binary is None:
            rscript_binary = cls.RSCRIPT
        count_matrix = '.biographkernels_count_matrix.csv.gz'
        df.to_csv(count_matrix, compression='gzip', index=True, index_label='id')
        output_file = '.biographkernels_result.csv.gz'
        call = [rscript_binary,
                cls.SCRIPT,
                '--data-matrix=%s' % count_matrix,
                '--output-file=%s' % output_file,
                '--path-of-script=%s' % __FILEPATH__]
        if verbose:
            call.append('--verbose')
        subprocess.run(call, check=True)
        ret = pd.read_table(output_file, sep=',', compression='gzip', index_col=0)
        subprocess.run(['rm', count_matrix])
        subprocess.run(['rm', output_file])
        return ret
