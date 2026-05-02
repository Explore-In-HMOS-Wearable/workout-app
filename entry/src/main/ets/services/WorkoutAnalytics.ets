import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x1001;
const TAG = 'WorkoutAnalytics';

export class WorkoutAnalytics {
  static log(eventName: string, detail: string = '') {
    hilog.info(DOMAIN, TAG, '%{public}s %{public}s', eventName, detail);
  }
}
