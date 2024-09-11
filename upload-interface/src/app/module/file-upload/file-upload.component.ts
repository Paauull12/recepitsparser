import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FileUploadService } from '../../core/service/file-upload/file-upload.service';
import { finalize } from 'rxjs';
import { HttpEventType } from '@angular/common/http';
import { UploadResponse } from '../../core/model/upload-response.model';

@Component({
  selector: 'app-new-file-upload',
  templateUrl: './file-upload.component.html',
  styleUrl: './file-upload.component.scss',
})
export class FileUploadComponent {
  public readonly accept: string = 'image/png, image/jpeg, .pdf';
  public maxFilesize: number = 10 * 1024 * 1024; // too much?
  public file: File | null = null;
  public response: UploadResponse | null = null;
  public filesizeError = false;
  public error: string | null = '';
  public uploadProgress: number = 0;
  public uploadedFileName: string = '';
  public uploading = false;

  @Output() uploadedDocUUID = new EventEmitter<string>();
  @Output() uploadedFile = new EventEmitter<File>(); // New Output to emit the file
  @Output() textWithTotal = new EventEmitter<string>();

  @Input() isChecked: boolean = false;

  // Handles drag-and-droped file
  onFileDropped(files: FileList) {
    if (this.uploading) {
      return;
    }
    this.prepareFilesList(files);
  }

  // Handles file selected from system
  public fileBrowseHandler(event: Event): void {
    if (this.uploading) {
      return;
    }
    const input = event.target as HTMLInputElement;
    this.prepareFilesList(input.files);
    input.value = '';
  }

  private prepareFilesList(files: FileList | null): void {
    if (!files?.length) {
      return;
    }
    this.file = files[0];
    this.filesizeError = this.file.size > this.maxFilesize;
    this.error = null;
    this.response = null;
    if (!this.filesizeError) {
      this.upload();
      this.uploadedFile.emit(this.file);
    }
  }

  constructor(private fileUploadService: FileUploadService) {}

  // Handles upload logic and updates progress bar accordingly
  // When finalized, emits the doc UUID from the response to the dental-quote component
  public upload(): void {
    this.uploadProgress = 1;
    this.uploading = true;
    this.error = null;
    this.response = null;
    this.uploadedFileName = this.file!.name;

    this.textWithTotal.emit('');

    this.fileUploadService
      .uploadFile(this.file!, this.isChecked)
      .pipe(
        finalize(() => {
          this.uploading = false;
          this.uploadProgress = 100;
          this.uploadedDocUUID.emit(this.response?.uid);
        })
      )
      .subscribe({
        next: event => {
          switch (event.type) {
            case HttpEventType.UploadProgress:
              this.uploadProgress = Math.round(
                100 * (event.loaded / event.total!)
              );
              break;
            case HttpEventType.Response:
              this.response = event.body!;
              this.textWithTotal.emit(this.response?.total || '');
              break;
          }
        },
        error: error => (this.error = error.message),
      });
  }
}
