//
//  MyTableViewCell.swift
//  FirebaseDB
//
//  Created by Derek 2019/5/3.
//

import UIKit

@objc protocol MyTableViewCellDelegate {
	@objc optional func handleVote(_ uid: String)
}

class MyTableViewCell: UITableViewCell {
	var delegate: MyTableViewCellDelegate? = nil
	
	var uid = ""
	
	lazy var nameLabel: UILabel = {()-> UILabel in
		
		let lbl = UILabel()
		lbl.numberOfLines = 0
		
		return lbl
	}()
	
	lazy var detailLabel: UILabel = {()-> UILabel in
		
		let lbl = UILabel()
		lbl.numberOfLines = 0
		
		return lbl
	}()
	
	lazy var imgView: UIImageView = {()-> UIImageView in
		
		let imgv = UIImageView()
		
		return imgv
	}()
	
	lazy var voteBtn: UIButton = {()-> UIButton in
		
		let btn = UIButton()
		btn.addTarget(self, action: #selector(voteClick), for: .touchUpInside)
		btn.setTitle("Vote", for: .normal)
		btn.setTitleColor(.blue, for: .normal)
		btn.setTitleColor(.gray, for: .disabled)
		return btn
	}()
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
		
		let marginGuide = contentView.layoutMarginsGuide
		
		contentView.addSubview(imgView)
		imgView.translatesAutoresizingMaskIntoConstraints = false
		imgView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
		imgView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
		imgView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		imgView.widthAnchor.constraint(equalToConstant: 80).isActive = true
		imgView.heightAnchor.constraint(equalToConstant: 80).isActive = true
		
        // configure titleLabel
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        nameLabel.numberOfLines = 0
		
        contentView.addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 10).isActive = true
        detailLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
		detailLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
	
		contentView.addSubview(voteBtn)
		voteBtn.translatesAutoresizingMaskIntoConstraints = false
		voteBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
		voteBtn.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
		voteBtn.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    }
	@objc func voteClick(_ sender: Any) {
		self.delegate?.handleVote?(uid)
	}
}
