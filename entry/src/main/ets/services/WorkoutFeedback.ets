import { vibrator } from '@kit.SensorServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x1002;
const TAG = 'WorkoutFeedback';

export enum FeedbackCue {
  START = 'start',
  COUNTDOWN = 'countdown',
  REST = 'rest',
  COMPLETE = 'complete',
  CONTROL = 'control'
}

export class WorkoutFeedback {
  static async play(cue: FeedbackCue): Promise<void> {
    let duration = 60;

    if (cue === FeedbackCue.START) {
      duration = 120;
    } else if (cue === FeedbackCue.REST) {
      duration = 180;
    } else if (cue === FeedbackCue.COMPLETE) {
      duration = 320;
    }

    try {
      await vibrator.startVibration({
        type: 'time',
        duration: duration
      }, {
        usage: 'physicalFeedback'
      });
    } catch (error) {
      hilog.warn(DOMAIN, TAG, 'Feedback cue failed: %{public}s', JSON.stringify(error));
    }
  }
}
