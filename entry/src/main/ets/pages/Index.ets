import { ArcList, ArcListAttribute, ArcListItem, ArcListItemAttribute, LengthUnit } from '@kit.ArkUI';
import { WorkoutAnalytics } from '../services/WorkoutAnalytics';
import { FeedbackCue, WorkoutFeedback } from '../services/WorkoutFeedback';
import { Circuits } from './Circuits';
import { Complete } from './Complete';
import { Reminders } from './Reminders';
import { Settings } from './Settings';
import { Workout, WorkoutParams } from './Workout';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string, param: object) {
    if (name === 'Circuits') {
      Circuits()
    } else if (name === 'Workout') {
      Workout()
    } else if (name === 'Settings') {
      Settings()
    } else if (name === 'Complete') {
      Complete()
    } else if (name === 'Reminders') {
      Reminders()
    }
  }

  @Builder
  CustomCard(cardIcon: Resource, title: ResourceStr, subtitle: ResourceStr, analyticsName: string,
    random: boolean = false, route: string = 'Workout', showMenu: boolean = true) {
    Column({ space: 5 }) {
      Row() {
        Row() {
          Image(cardIcon).width(22).height(22)
        }
        .width(38)
        .height(38)
        .borderRadius(19)
        .backgroundColor($r('app.color.surface_soft'))
        .justifyContent(FlexAlign.Center)

        if (showMenu) {
          Image($r('app.media.dots'))
            .width(26)
            .height(26)
            .padding(5)
            .borderRadius(13)
            .onClick(() => {
              WorkoutFeedback.play(FeedbackCue.CONTROL)
              WorkoutAnalytics.log('circuits_opened')
              this.pageStack.pushPath({ name: 'Circuits' })
            })
            .stateStyles({
              normal: {
                .backgroundColor($r('app.color.surface_soft'))
              },
              pressed: {
                .backgroundColor($r('app.color.surface_pressed'))
              }
            })
        }
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Text(title)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Bold)

      Text(subtitle)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('84%')
    .backgroundColor($r('app.color.surface'))
    .padding(10)
    .borderRadius(12)
    .border({
      width: 1,
      color: $r('app.color.accent_soft')
    })
    .stateStyles({
      pressed: {
        .backgroundColor($r('app.color.surface_pressed'))
      }
    })
    .onClick(() => {
      WorkoutFeedback.play(FeedbackCue.CONTROL)
      WorkoutAnalytics.log('home_card_selected', `title=${analyticsName}, random=${random}`)
      this.pageStack.pushPath({
        name: route,
        param: new WorkoutParams(random)
      })
    })
  }

  build() {
    Navigation(this.pageStack) {
      RelativeContainer() {
        ArcList({ initialIndex: 1 }) {
          ArcListItem() {
            Text($r('app.string.quick_starters'))
              .fontColor($r('app.color.text_primary'))
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 12 })
          }

          ArcListItem() {
            this.CustomCard($r('app.media.man'), $r('app.string.full_body'), $r('app.string.suggested'), 'full_body');
          }.autoScale(false)

          ArcListItem() {
            this.CustomCard($r('app.media.random'), $r('app.string.quick_starter'), $r('app.string.random'),
              'quick_starter', true);
          }.autoScale(false)

          ArcListItem() {
            this.CustomCard($r('app.media.reminder'), $r('app.string.daily_reminder'), $r('app.string.schedule'),
              'daily_reminder', false, 'Reminders', false);
          }.autoScale(false)
        }
        .height('100%')
        .space({
          unit: LengthUnit.PX,
          value: 12
        })
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .height('100%')
    .width('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.PagesMap)
    .backgroundColor($r('app.color.page_background'))
  }
}
