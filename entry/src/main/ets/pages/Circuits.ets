import { WorkoutAnalytics } from '../services/WorkoutAnalytics';
import { FeedbackCue, WorkoutFeedback } from '../services/WorkoutFeedback';

@Component
export struct Circuits {
  @StorageLink('circuit') circuit: number = 1;

  @Builder
  RoundButton(label: ResourceStr, action: () => void) {
    Button(label)
      .type(ButtonType.Circle)
      .width(42)
      .height(42)
      .fontSize(18)
      .backgroundColor($r('app.color.surface'))
      .fontColor($r('app.color.text_primary'))
      .onClick(action)
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Text($r('app.string.circuits'))
          .fontSize(17)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)

        Row({ space: 14 }) {
          this.RoundButton($r('app.string.minus'), () => {
            if (this.circuit > 1) {
              this.circuit--
              WorkoutFeedback.play(FeedbackCue.CONTROL)
              WorkoutAnalytics.log('circuit_changed', `circuit=${this.circuit}`)
            }
          })

          Text(this.circuit.toString())
            .fontSize(28)
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .width(48)
            .textAlign(TextAlign.Center)

          this.RoundButton($r('app.string.plus'), () => {
            if (this.circuit < 5) {
              this.circuit++
              WorkoutFeedback.play(FeedbackCue.CONTROL)
              WorkoutAnalytics.log('circuit_changed', `circuit=${this.circuit}`)
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
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
