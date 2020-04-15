import UIKit
import app

class ViewController: UIViewController, ReactorPageHandler {

    private let reactor = Reactor()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onPageLoaded(page: KotlinInt?, posts: [Post]) {

    }

    @IBOutlet weak var label: UILabel!
}
