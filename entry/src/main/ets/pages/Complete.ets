import { WorkoutAnalytics } from '../services/WorkoutAnalytics';
import { FeedbackCue, WorkoutFeedback } from '../services/WorkoutFeedback';

@Component
export struct Complete {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Row() {
          Text($r('app.string.complete_badge'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.page_background'))
        }
        .width(58)
        .height(58)
        .borderRadius(29)
        .backgroundColor($r('app.color.accent'))
        .justifyContent(FlexAlign.Center)

        Text($r('app.string.workout_complete'))
          .fontSize(21)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .wordBreak(WordBreak.BREAK_WORD);

        Button($r('app.string.done'))
          .type(ButtonType.ROUNDED_RECTANGLE)
          .width(72)
          .height(34)
          .backgroundColor($r('app.color.surface'))
          .fontColor($r('app.color.text_primary'))
          .onClick(() => {
            WorkoutFeedback.play(FeedbackCue.CONTROL)
            WorkoutAnalytics.log('complete_done')
            this.pageStack.clear()
          })
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
