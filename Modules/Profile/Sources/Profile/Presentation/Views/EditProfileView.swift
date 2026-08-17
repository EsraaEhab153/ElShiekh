import SwiftUI
import Common

public struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    public init(viewModel: EditProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // First Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.App.grayText)
                    
                    TextField("Enter first name", text: $viewModel.firstName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                // Last Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.App.grayText)
                    
                    TextField("Enter last name", text: $viewModel.lastName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                // Phone Number Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.App.grayText)
                    
                    TextField("Enter phone number", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Color.App.destructive)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                
                // Save Button
                Button(action: {
                    viewModel.saveProfile()
                }) {
                    HStack {
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Text("Save Changes")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.isSaving ? Color.App.primary.opacity(0.7) : Color.App.primary)
                    .cornerRadius(28)
                }
                .disabled(viewModel.isSaving)
                .padding(.top, 16)
                
            }
            .padding(24)
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.isSuccess) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
