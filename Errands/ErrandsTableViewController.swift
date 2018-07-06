import UIKit

struct Errand {

    var name : String

}

class ErrandsModel {

    var errands = [Errand(name: "Apple")] {
        didSet {
            self.onChange?()
        }
    }

    var onChange : (() -> Void)?
    var onError : ((Error) -> Void)?

    init() {
    }

    func addErrand(name : String) {
        self.errands.append(Errand(name: name))
    }

    func delete(at index : Int) {
        self.errands.remove(at: index)
    }

    @objc func refresh() {
    }

}

class ErrandsTableViewController: UITableViewController {

    var model = ErrandsModel()

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.model.onError = { error in
            let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: nil)
            self.refreshControl!.endRefreshing()
        }

        self.model.onChange = {
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self.model, action: #selector(ErrandsModel.refresh), for: .valueChanged)
        self.refreshControl = refreshControl

        self.model.refresh()
    }

    // MARK: - Actions

    @IBAction func addErrand() {

        let alertController = UIAlertController(title: "Add Errand", message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let name = alertController.textFields!.first!.text!
            if name.count > 0 {
                self.model.addErrand(name: name)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Protocol UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.errands.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)

        let errand = model.errands[indexPath.row]
        cell.textLabel?.text = errand.name

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.model.delete(at: indexPath.row)
            // tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
