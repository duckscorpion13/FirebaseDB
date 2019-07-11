//
//  MyTableViewCell.swift
//  StreetView
//
//  Created by Derek 2019/5/3.
//

import UIKit

class MyTableViewCell: UITableViewCell {
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
        // configure titleLabel
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        nameLabel.numberOfLines = 0
        
        contentView.addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        detailLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
	
		contentView.addSubview(imgView)
		imgView.translatesAutoresizingMaskIntoConstraints = false
		imgView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
		imgView.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
		imgView.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		imgView.widthAnchor.constraint(equalToConstant: 50).isActive = true
		imgView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

}
