import { common } from '@kit.AbilityKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { WorkoutAnalytics } from '../services/WorkoutAnalytics';
import { FeedbackCue, WorkoutFeedback } from '../services/WorkoutFeedback';

const BUNDLE_NAME = 'com.hmosdemos.wearable.workout_app'
const ABILITY_NAME = 'EntryAbility'
const REMINDER_NOTIFICATION_ID = 3001
const STATUS_OFF = 0
const STATUS_ON = 1
const STATUS_FAILED = 2
const STATUS_CANCEL_FAILED = 3

@Component
export struct Reminders {
  @StorageLink('reminderId') reminderId: number = -1;
  @State hour: number = AppStorage.get('reminderHour') as number;
  @State minute: number = AppStorage.get('reminderMinute') as number;
  @State statusCode: number = STATUS_OFF;

  aboutToAppear(): void {
    if (this.reminderId >= 0) {
      this.statusCode = STATUS_ON
    }
  }

  getString(resource: Resource): string {
    try {
      return this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id)
    } catch (error) {
      WorkoutAnalytics.log('resource_string_failed', JSON.stringify(error))
      return ''
    }
  }

  changeHour(delta: number) {
    this.hour = (this.hour + delta + 24) % 24
    AppStorage.set('reminderHour', this.hour)
    WorkoutFeedback.play(FeedbackCue.CONTROL)
  }

  changeMinute(delta: number) {
    this.minute = (this.minute + delta + 60) % 60
    AppStorage.set('reminderMinute', this.minute)
    WorkoutFeedback.play(FeedbackCue.CONTROL)
  }

  async setReminder() {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      await notificationManager.requestEnableNotification(context)

      if (this.reminderId >= 0) {
        await reminderAgentManager.cancelReminder(this.reminderId)
      }

      const title = this.getString($r('app.string.reminder_notification_title'))
      const content = this.getString($r('app.string.reminder_notification_content'))
      const expiredContent = this.getString($r('app.string.reminder_notification_expired'))
      const snoozeContent = this.getString($r('app.string.reminder_notification_snooze'))

      const request: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: this.hour,
        minute: this.minute,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        title: title,
        content: content,
        expiredContent: expiredContent,
        snoozeContent: snoozeContent,
        snoozeTimes: 1,
        timeInterval: 10 * 60,
        ringDuration: 5,
        notificationId: REMINDER_NOTIFICATION_ID,
        slotType: notificationManager.SlotType.SERVICE_INFORMATION,
        wantAgent: {
          pkgName: BUNDLE_NAME,
          abilityName: ABILITY_NAME
        },
        maxScreenWantAgent: {
          pkgName: BUNDLE_NAME,
          abilityName: ABILITY_NAME
        }
      }

      const id = await reminderAgentManager.publishReminder(request)
      this.reminderId = id
      this.statusCode = STATUS_ON
      WorkoutFeedback.play(FeedbackCue.COMPLETE)
      WorkoutAnalytics.log('reminder_set', `hour=${this.hour}, minute=${this.minute}`)
    } catch (error) {
      this.statusCode = STATUS_FAILED
      WorkoutAnalytics.log('reminder_failed', JSON.stringify(error))
    }
  }

  async cancelReminder() {
    try {
      if (this.reminderId >= 0) {
        await reminderAgentManager.cancelReminder(this.reminderId)
      }
      this.reminderId = -1
      this.statusCode = STATUS_OFF
      WorkoutFeedback.play(FeedbackCue.CONTROL)
      WorkoutAnalytics.log('reminder_canceled')
    } catch (error) {
      this.statusCode = STATUS_CANCEL_FAILED
      WorkoutAnalytics.log('reminder_cancel_failed', JSON.stringify(error))
    }
  }

  formatTime(): string {
    const hourLabel = this.hour < 10 ? `0${this.hour}` : `${this.hour}`
    const minuteLabel = this.minute < 10 ? `0${this.minute}` : `${this.minute}`
    return `${hourLabel}:${minuteLabel}`
  }

  @Builder
  StatusText() {
    if (this.statusCode === STATUS_ON) {
      Text($r('app.string.reminder_status_on'))
        .fontSize(11)
        .fontColor($r('app.color.accent'))
    } else if (this.statusCode === STATUS_FAILED) {
      Text($r('app.string.reminder_status_failed'))
        .fontSize(11)
        .fontColor($r('app.color.danger'))
    } else if (this.statusCode === STATUS_CANCEL_FAILED) {
      Text($r('app.string.reminder_status_cancel_failed'))
        .fontSize(11)
        .fontColor($r('app.color.danger'))
    } else {
      Text($r('app.string.reminder_status_off'))
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
    }
  }

  @Builder
  Stepper(label: ResourceStr, value: string, onMinus: () => void, onPlus: () => void) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(10)
        .fontColor($r('app.color.text_secondary'))
      Row({ space: 8 }) {
        Button($r('app.string.minus'))
          .type(ButtonType.Circle)
          .width(34)
          .height(34)
          .backgroundColor($r('app.color.surface'))
          .fontColor($r('app.color.text_primary'))
          .onClick(onMinus)
        Text(value)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .width(30)
          .textAlign(TextAlign.Center)
        Button($r('app.string.plus'))
          .type(ButtonType.Circle)
          .width(34)
          .height(34)
          .backgroundColor($r('app.color.surface'))
          .fontColor($r('app.color.text_primary'))
          .onClick(onPlus)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
        Image($r('app.media.reminder'))
          .width(44)
          .height(44)

        Text($r('app.string.daily_reminder'))
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)

        Text(this.formatTime())
          .fontSize(27)
          .fontColor($r('app.color.accent'))
          .fontWeight(FontWeight.Bold)

        this.Stepper($r('app.string.hour'), this.hour.toString(), () => {
          this.changeHour(-1)
        }, () => {
          this.changeHour(1)
        })
        this.Stepper($r('app.string.minute'), this.minute.toString(), () => {
          this.changeMinute(-5)
        }, () => {
          this.changeMinute(5)
        })

        Row({ space: 8 }) {
          Button($r('app.string.set'))
            .width(64)
            .height(34)
            .backgroundColor($r('app.color.accent'))
            .fontColor($r('app.color.page_background'))
            .onClick(() => {
              this.setReminder()
            })
          Button($r('app.string.off'))
            .width(64)
            .height(34)
            .backgroundColor($r('app.color.surface'))
            .fontColor($r('app.color.text_primary'))
            .onClick(() => {
              this.cancelReminder()
            })
        }

        this.StatusText()
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .hideTitleBar(true)
  }
}
