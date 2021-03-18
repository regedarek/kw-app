import React from 'react';
import 'whatwg-fetch';
import FileUploader from "./fileUploader";
import FileList from "./fileList";

import axios from "axios";

const uploadPath = "/api/uploads"

class FileUploaderContainer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
        files: props.files || [],
        maxFiles: this.props.maxFiles || 5,
        maxFileSize: this.props.maxFileSize || 5 * 1024 * 1024,
        uploadProgress: null,
        userId: props.userId,
        uploadableId: props.uploadableId,
        uploadableType: props.uploadableType,
    };
  }
  
  onFileChange(event) {
    const uploadedFile = event.target.files[0]

    if (uploadedFile.size > this.state.maxFileSize) {
      alert(`Plik przekracza maksymalny rozmiar: ${this.state.maxFileSize/1024/1024} MB`);
      return;
    }

    const {userId, uploadableId, uploadableType} = this.state;

    const data = new FormData()
    data.append('upload[file]', uploadedFile)
    data.append('upload[user_id]', userId)
    data.append('upload[uploadable_id]', uploadableId)
    data.append('upload[uploadable_type]', uploadableType)

    axios.request({
      method: "post", 
      url: uploadPath, 
      data: data, 
      onUploadProgress: (f) => {  
        this.setState({
          uploadProgress: f.loaded / f.total
        })
      }
    }).then (response => {
      this.setState({
        uploadProgress: null,
        files: [...this.state.files, {...response.data, name: uploadedFile.name}]
      })
    })
    .catch(function (error) {
      console.log(error);
    });
  }

  onFileRemove(id) {
    if (window.confirm("Czy na pewno chcesz usunąć zdjęcie? Tej akcji nie da się cofnąć")) {
      
      this.setState({
        files: this.state.files.filter(el => el.id !== id)
      })
    }
  }

  render() {
    return (
        <>
          <FileList files={this.state.files} onFileRemove={this.onFileRemove.bind(this)}/>
          {this.state.files.length < this.state.maxFiles && !this.state.uploadProgress && <FileUploader maxSize={this.state.maxFileSize} onFileChange={this.onFileChange.bind(this)} />}
          {this.state.uploadProgress && (
            <div className="progress" role="progressbar" tabIndex="0" aria-valuenow={parseInt(this.state.uploadProgress*100)} aria-valuemin="0" aria-valuemax="100">
              <div className="progress-meter" style={{width: parseInt(this.state.uploadProgress*100) + "%"}}></div>
            </div>
          )}
        </>
    );
  }
}

export default FileUploaderContainer;
