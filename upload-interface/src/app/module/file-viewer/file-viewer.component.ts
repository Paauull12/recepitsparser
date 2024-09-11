import { Component, Input  } from '@angular/core';

@Component({
  selector: 'app-file-viewer',
  templateUrl: './file-viewer.component.html',
  styleUrls: ['./file-viewer.component.scss']  // This should point to your SCSS file
})
export class FileViewerComponent {
  @Input() file: File | null = null;
  @Input() textWithTotal: string = '';
  
  fileUrl(): string | undefined {
    return this.file ? URL.createObjectURL(this.file) : undefined;
  }
}
