import { WorkoutAnalytics } from '../services/WorkoutAnalytics';
import { FeedbackCue, WorkoutFeedback } from '../services/WorkoutFeedback';

@Component
export struct Settings {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageLink('currentIndex') currentIndex: number = 0;
  @StorageLink('animationCount') animationCount: number = 0;
  @StorageLink('circuit') circuit: number = 1;

  @Builder
  CustomButton(image: Resource, action: () => void) {
    Column() {
      Image(image)
        .width(24)
        .height(24)
    }
    .backgroundColor($r('app.color.surface'))
    .borderRadius(24)
    .width(48)
    .height(48)
    .clickEffect({
      level: ClickEffectLevel.HEAVY
    })
    .padding(8)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      action()
    })
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Text($r('app.string.workout_position', this.currentIndex + 1, this.animationCount * this.circuit))
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .fontWeight(FontWeight.Medium)

        Row({ space: 12 }) {
          this.CustomButton($r('app.media.backward'), () => {
            if (this.currentIndex > 0) {
              this.currentIndex--;
              WorkoutFeedback.play(FeedbackCue.CONTROL)
              WorkoutAnalytics.log('workout_previous', `index=${this.currentIndex + 1}`)
            }
          })

          Image($r('app.media.play'))
            .width(52)
            .height(52)
            .borderRadius(26)
            .backgroundColor($r('app.color.accent'))
            .onClick(() => {
              WorkoutFeedback.play(FeedbackCue.CONTROL)
              WorkoutAnalytics.log('workout_resumed', `index=${this.currentIndex + 1}`)
              this.pageStack.pop()
            })

          this.CustomButton($r('app.media.next'), () => {
            if (this.currentIndex < (this.animationCount * this.circuit) - 1) {
              this.currentIndex++
              WorkoutFeedback.play(FeedbackCue.CONTROL)
              WorkoutAnalytics.log('workout_next', `index=${this.currentIndex + 1}`)
            }
          })
        }

        this.CustomButton($r('app.media.cross'), () => {
          WorkoutFeedback.play(FeedbackCue.CONTROL)
          WorkoutAnalytics.log('workout_canceled', `index=${this.currentIndex + 1}`)
          this.pageStack.clear()
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
  }
}
