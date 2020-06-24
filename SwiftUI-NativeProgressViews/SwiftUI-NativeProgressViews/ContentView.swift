import SwiftUI
import Combine

class LoadingController: ObservableObject {
    @Published var progress: Progress

    @Published var finished: Bool = false

    private var timerCancellable: AnyCancellable?

    init() {
        progress = Progress(totalUnitCount: 100)
    }

    func startLoading() {
        timerCancellable = Timer.publish(every: 0.025, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.progress.completedUnitCount += 1
                if self.progress.isFinished {
                    self.timerCancellable = nil
                    self.finished = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.finished = false
                        self.progress.completedUnitCount = 0
                        self.startLoading()
                    }
                }
            }
    }
}

struct ContentView: View {

    @ObservedObject var loadingController = LoadingController()

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Divider()

            ProgressView("Loading")

            Divider()

            ProgressView("Percent Complete", value: /*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/, total: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)

            Divider()


            ProgressView(loadingController.progress)
                .accentColor(loadingController.finished ? .green : .blue)
                .onAppear {
                    loadingController.startLoading()
                }

            Divider()

            ProgressView(loadingController.progress)
                .frame(width: 80.0, height: 80.0)
                .progressViewStyle(AwesomeProgressViewStyle())

            ProgressView(loadingController.progress)
                .frame(width: 40.0, height: 40.0)
                .progressViewStyle(MyCircularProgressViewStyle())
                .foregroundColor(.blue)

        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

struct AwesomeProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            .foregroundColor(.gray)
            .overlay(
                TriangleShape(progress: configuration.fractionCompleted ?? 0)
                    .fill(Color.blue)
                    .overlay(configuration.label)
                    .foregroundColor(.white)
                    .clipped()
            )
    }
}

struct MyCircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { proxy in
            Circle()
                .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                .overlay(
                    Circle()
                        .fill()
                        .frame(width: proxy.size.width * CGFloat((configuration.fractionCompleted ?? 0)),
                               height: proxy.size.height * CGFloat((configuration.fractionCompleted ?? 0)))
                )
        }
    }
}

struct TriangleShape: Shape {
    let progress: Double

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: rect.origin)
            p.addLine(to: CGPoint(x: rect.origin.x + rect.width * 2 * CGFloat(progress), y: 0))
            p.addLine(to: CGPoint(x: 0, y: rect.origin.y + rect.height * 2 * CGFloat(progress)))
            p.addLine(to: rect.origin)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
