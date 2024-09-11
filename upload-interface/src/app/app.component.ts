import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'upload-interface';
  
  fileUrl: string | null = null;

  onUploadDone(uuid: string) {
    this.fileUrl = this.generateFileUrl(uuid);
  }

  generateFileUrl(uuid: string): string {
    return `https://your-backend-api.com/files/${uuid}`;
  }
}
