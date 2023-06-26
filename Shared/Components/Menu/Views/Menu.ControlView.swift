//
//  Menu.ControlView.swift
//  Bitsy
//
//  Created by Ritesh Pakala on 6/26/23.
//

import Foundation
import Granite
import MarbleKit
import SwiftUI

extension Menu {
    static var controlsHeight: CGFloat {
        55 + 16
    }
    
    var controlView: some View {
        VStack {
            HStack(spacing: 16) {
                Button {
                    center.toggleEditStream.send()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .font(.title3.bold())
                        .frame(width: 22, height: 22)
                }.buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button {
                    center.control.send(Menu.Control.Meta(control: .clip))
                } label: {
                    Image(systemName: "scissors")
                        .font(.title3.bold())
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 8)
                
                HStack {
                    Button {
                        center.control.send(Menu.Control.Meta(control: .toggleFX))
                    } label: {
                        Image(systemName: "fx")
                            .font(.title3.bold())
                            .frame(width: 24, height: 24)
                            .foregroundColor(state.fxEnabled ? .black : .white)
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if state.fxEnabled {
                        ForEach(MarbleEffect.effects2D, id: \.self) { effect in
                            
                            Button {
                                center.control.send(Menu.Control.Meta(control: .modifyFX(effect)))
                            } label: {
                                Text("\(effect.rawValue)")
                                    .font(.headline.bold())
                                    .frame(height: 24)
                                    .foregroundColor(state.fx.contains(effect) ? .white : .black)
                                    .padding(.horizontal, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4.0)
                                            .stroke(.white, lineWidth: 2.0)
                                            .background(state.fx.contains(effect) ? .black : .clear)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 4.0)
                        .stroke(.white, lineWidth: 2.0)
                        .background(state.fxEnabled ? .white : .clear)
                )
                .animation(.default, value: state.fxEnabled)
                
                Spacer()
                
                Button {
                    center.reset.send()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .resizable()
                        .font(.title3.bold())
                        .frame(width: 24, height: 24)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 32)
        }
        .frame(height: Menu.controlsHeight)
    }
}
